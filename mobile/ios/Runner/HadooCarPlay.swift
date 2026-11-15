import CarPlay
import Flutter
import UIKit

extension Notification.Name {
  static let hadooCatalogReady = Notification.Name("HadooCatalogReady")
}

/// CarPlay browses and selects through the same Dart catalog as Android Auto.
/// MPRemoteCommandCenter/Now Playing remain owned by LokalPlatform.
final class HadooCarPlayBridge {
  private let channel: FlutterMethodChannel
  private weak var controller: CPInterfaceController?
  private var observer: NSObjectProtocol?
  private var ready = false
  private var generation = 0
  private var lists: [(String, CPListTemplate)] = []

  init(messenger: FlutterBinaryMessenger) {
    channel = FlutterMethodChannel(name: "com.mossapps.flick/player", binaryMessenger: messenger)
    observer = NotificationCenter.default.addObserver(
      forName: .hadooCatalogReady, object: nil, queue: .main
    ) { [weak self] _ in
      self?.ready = true
      self?.refresh()
    }
  }

  deinit { if let observer = observer { NotificationCenter.default.removeObserver(observer) } }

  func connect(_ controller: CPInterfaceController) {
    generation += 1
    self.controller = controller
    let sections: [(String, String, String)] = [
      ("lokal/downloads", "Offline", "arrow.down.circle"),
      ("lokal/library", "Library", "music.note.list"),
      ("lokal/playlists", "Playlists", "list.bullet"),
      ("lokal/likes", "Liked", "heart"),
    ]
    lists = sections.map { id, title, symbol in
      let template = CPListTemplate(title: title, sections: [])
      template.tabTitle = title
      template.tabImage = UIImage(systemName: symbol)
      template.emptyViewTitleVariants = ["Loading Hadoo…"]
      template.emptyViewSubtitleVariants = ["Your music will appear when the library is ready."]
      return (id, template)
    }
    controller.setRootTemplate(CPTabBarTemplate(templates: lists.map { $0.1 }), animated: false,
      completion: nil)
    refresh()
  }

  func disconnect() {
    generation += 1
    controller = nil
    lists = []
  }

  func refresh() {
    guard ready, controller != nil else { return }
    for (id, template) in lists { load(id, into: template) }
  }

  // A stalled resolver or a disappearing Flutter engine must release the
  // CarPlay selection spinner. Late replies cannot complete it a second time.
  private func request(_ method: String, _ arguments: [String: Any],
                       completion: @escaping (Any?) -> Void) {
    var finished = false
    let finish: (Any?) -> Void = { value in
      guard !finished else { return }
      finished = true
      completion(value)
    }
    let timeout = DispatchWorkItem { finish(nil) }
    DispatchQueue.main.asyncAfter(deadline: .now() + 30, execute: timeout)
    channel.invokeMethod(method, arguments: arguments) { value in
      timeout.cancel()
      finish(value)
    }
  }

  private func load(_ parent: String, into template: CPListTemplate) {
    let current = generation
    request("androidAutoBrowse", ["parentId": parent]) { [weak self, weak template] result in
      guard let self = self, let template = template,
            self.controller != nil, self.generation == current else { return }
      guard let entries = result as? [[String: Any]] else {
        let retry = CPListItem(text: "Library unavailable", detailText: "Tap to try again")
        retry.handler = { [weak self, weak template] _, complete in
          if let template = template { self?.load(parent, into: template) }
          complete()
        }
        template.updateSections([CPListSection(items: [retry])])
        return
      }
      template.emptyViewTitleVariants = ["No music here yet"]
      template.emptyViewSubtitleVariants = ["Add music or save downloads in Hadoo on your phone."]
      let items: [CPListItem] = entries.compactMap { entry in
        guard let id = entry["id"] as? String, let title = entry["title"] as? String else { return nil }
        let playable = entry["playable"] as? Bool == true
        let item = CPListItem(text: title, detailText: entry["subtitle"] as? String)
        item.accessoryType = playable ? .none : .disclosureIndicator
        item.handler = { [weak self] _, complete in
          guard let self = self, self.generation == current,
                let controller = self.controller else { complete(); return }
          if playable {
            self.request("androidAutoPlayMediaId", ["mediaId": id]) { [weak self] result in
              complete()
              guard let self = self, self.generation == current, self.controller != nil else { return }
              if result as? Bool == true {
                controller.pushTemplate(CPNowPlayingTemplate.shared, animated: true, completion: nil)
              } else {
                let dismiss = CPAlertAction(title: "OK", style: .default) { _ in
                  controller.dismissTemplate(animated: true, completion: nil)
                }
                controller.presentTemplate(CPAlertTemplate(
                  titleVariants: ["Couldn’t play this song. Try another track or check the source on your phone."],
                  actions: [dismiss]), animated: true, completion: nil)
              }
            }
          } else {
            let child = CPListTemplate(title: title, sections: [])
            child.emptyViewTitleVariants = ["Loading…"]
            controller.pushTemplate(child, animated: true, completion: nil)
            self.load(id, into: child)
            complete()
          }
        }
        return item
      }
      template.updateSections(items.isEmpty ? [] : [CPListSection(items: items)])
    }
  }
}

final class HadooCarPlaySceneDelegate: UIResponder, CPTemplateApplicationSceneDelegate {
  private var bridge: HadooCarPlayBridge?

  func templateApplicationScene(_ templateApplicationScene: CPTemplateApplicationScene,
                                didConnect interfaceController: CPInterfaceController) {
    guard let app = UIApplication.shared.delegate as? AppDelegate else { return }
    bridge = app.ensureCarPlayBridge()
    bridge?.connect(interfaceController)
  }

  func templateApplicationScene(_ templateApplicationScene: CPTemplateApplicationScene,
                                didDisconnectInterfaceController interfaceController: CPInterfaceController) {
    bridge?.disconnect()
    bridge = nil
  }
}
