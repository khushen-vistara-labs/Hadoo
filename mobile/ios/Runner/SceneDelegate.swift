import Flutter
import UIKit

class SceneDelegate: FlutterSceneDelegate {
  override func scene(_ scene: UIScene, willConnectTo session: UISceneSession,
                      options connectionOptions: UIScene.ConnectionOptions) {
    if let app = UIApplication.shared.delegate as? AppDelegate,
       let engine = app.carPlayEngine, let windowScene = scene as? UIWindowScene {
      // Storyboard loading is disabled for this case by AppDelegate's scene
      // configuration, so no second Dart queue/Isar owner is constructed.
      let phoneWindow = UIWindow(windowScene: windowScene)
      phoneWindow.rootViewController = FlutterViewController(engine: engine, nibName: nil, bundle: nil)
      window = phoneWindow
      registerSceneLifeCycle(with: engine)
      phoneWindow.makeKeyAndVisible()
    }
    super.scene(scene, willConnectTo: session, options: connectionOptions)
    (UIApplication.shared.delegate as? AppDelegate)?.openDocuments(connectionOptions.urlContexts.map { $0.url })
  }

  override func scene(_ scene: UIScene, openURLContexts URLContexts: Set<UIOpenURLContext>) {
    super.scene(scene, openURLContexts: URLContexts)
    (UIApplication.shared.delegate as? AppDelegate)?.openDocuments(URLContexts.map { $0.url })
  }
}
