import Flutter
import UIKit

@_silgen_name("lokal_soulseek_suspend") private func suspendSoulseek()
@_silgen_name("lokal_soulseek_resume") private func resumeSoulseek()

@main
@objc class AppDelegate: FlutterAppDelegate, FlutterImplicitEngineDelegate {
  private(set) var carPlayEngine: FlutterEngine?
  private var carPlayBridge: HadooCarPlayBridge?
  private var lokalPlatform: LokalPlatform?
  private let transferHost = LokalTransferHost()
  private var transferBridge: LokalTransferBridge?
  #if DEBUG
  private var transferIntegrationHarness: LokalTransferIntegrationHarness?
  private var daemonProbe: LokalTransferDaemonProbe?
  #endif
  private var lifecycleObservers: [NSObjectProtocol] = []
  private var protectedDataObserver: NSObjectProtocol?
  private var pendingDocuments: [URL] = []

  func openDocuments(_ urls: [URL]) {
    if let platform = lokalPlatform { platform.openDocuments(urls) }
    else { pendingDocuments.append(contentsOf: urls.filter { $0.isFileURL }) }
  }
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    transferHost.start()
    #if DEBUG
    do { daemonProbe = try LokalTransferDaemonProbe(); daemonProbe?.start() }
    catch { NSLog("Isolated daemon probe configuration refused") }
    #endif
    lifecycleObservers = [
      NotificationCenter.default.addObserver(forName: UIApplication.didEnterBackgroundNotification,
        object: nil, queue: .main) { [weak self] _ in
          suspendSoulseek()
          #if DEBUG
          DispatchQueue.main.async { self?.daemonProbe?.backgrounded() }
          #endif
        },
      NotificationCenter.default.addObserver(forName: UIApplication.didBecomeActiveNotification,
        object: nil, queue: .main) { _ in resumeSoulseek() },
    ]
    protectedDataObserver = NotificationCenter.default.addObserver(
      forName: UIApplication.protectedDataDidBecomeAvailableNotification,
      object: nil, queue: .main) { [host = transferHost] _ in host.start() }
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }

  override func application(_ application: UIApplication,
                            configurationForConnecting connectingSceneSession: UISceneSession,
                            options: UIScene.ConnectionOptions) -> UISceneConfiguration {
    if connectingSceneSession.role == .windowApplication, carPlayEngine != nil {
      let config = UISceneConfiguration(name: "flutter", sessionRole: .windowApplication)
      config.delegateClass = SceneDelegate.self
      config.storyboard = nil
      return config
    }
    return UISceneConfiguration(name: connectingSceneSession.role.rawValue == "CPTemplateApplicationSceneSessionRoleApplication"
      ? "Hadoo CarPlay" : "flutter", sessionRole: connectingSceneSession.role)
  }

  override func application(
    _ application: UIApplication,
    handleEventsForBackgroundURLSession identifier: String,
    completionHandler: @escaping () -> Void
  ) {
    #if DEBUG
    if let probe = daemonProbe, probe.identifier == identifier {
      probe.handleBackgroundEvents(completionHandler)
      return
    }
    #endif
    guard identifier == LokalTransferRuntime.sessionIdentifier else {
      super.application(application, handleEventsForBackgroundURLSession: identifier,
        completionHandler: completionHandler)
      return
    }
    // This path works before Flutter initializes; importing into the library
    // is separate from retaining files and acknowledging native OS delivery.
    transferHost.handleBackgroundEvents(completion: completionHandler)
  }

  func didInitializeImplicitFlutterEngine(_ engineBridge: FlutterImplicitEngineBridge) {
    GeneratedPluginRegistrant.register(with: engineBridge.pluginRegistry)
    configureServices(messenger: engineBridge.applicationRegistrar.messenger())
  }

  /// A car-only launch has no phone window to create the implicit engine.
  /// Retain a headless engine and attach the phone to it if opened later.
  func ensureCarPlayBridge() -> HadooCarPlayBridge? {
    if let bridge = carPlayBridge { return bridge }
    let engine = FlutterEngine(name: "hadoo.carplay", project: nil, allowHeadlessExecution: true)
    carPlayEngine = engine
    guard engine.run() else { carPlayEngine = nil; return nil }
    GeneratedPluginRegistrant.register(with: engine)
    configureServices(messenger: engine.binaryMessenger)
    return carPlayBridge
  }

  private func configureServices(messenger: FlutterBinaryMessenger) {
    let audioProbe = FlutterMethodChannel(
      name: "com.icemonkey.hadoo/audio_probe", binaryMessenger: messenger)
    audioProbe.setMethodCallHandler { call, result in
      guard call.method == "monochrome" else {
        result(FlutterMethodNotImplemented)
        return
      }
      guard #available(iOS 17.0, *), let id = call.arguments as? String,
        id.range(of: #"^[0-9]{15,20}$"#, options: .regularExpression) != nil,
        let url = URL(string: "https://tracks.monochrome.st/track/\(id)")
      else {
        result(false)
        return
      }
      Task { @MainActor in
        result(await Self.readsFlacHeader(url))
      }
    }
    carPlayBridge = HadooCarPlayBridge(messenger: messenger)
    lokalPlatform = LokalPlatform(messenger: messenger)
    transferBridge = LokalTransferBridge(
      messenger: messenger, host: transferHost)
    #if DEBUG
    transferIntegrationHarness = LokalTransferIntegrationHarness(
      messenger: messenger)
    #endif
    lokalPlatform?.openDocuments(pendingDocuments)
    pendingDocuments = []
  }

  private static func readsFlacHeader(_ url: URL) async -> Bool {
    var request = URLRequest(url: url, cachePolicy: .reloadIgnoringLocalCacheData,
      timeoutInterval: 4)
    request.httpShouldHandleCookies = false
    request.setValue("bytes=0-16383", forHTTPHeaderField: "Range")
    do {
      let (bytes, response) = try await URLSession.shared.bytes(for: request)
      defer { bytes.task.cancel() }
      guard let http = response as? HTTPURLResponse,
        http.url?.scheme == "https", http.url?.host == url.host,
        [200, 206].contains(http.statusCode)
      else { return false }
      var body = bytes.makeAsyncIterator()
      for expected in "fLaC".utf8 {
        guard try await body.next() == expected else { return false }
      }
      return true
    } catch {
      return false
    }
  }

}
