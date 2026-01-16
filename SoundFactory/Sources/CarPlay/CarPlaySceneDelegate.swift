import CarPlay

class CarPlaySceneDelegate: UIResponder, CPTemplateApplicationSceneDelegate {
    
    var interfaceController: CPInterfaceController?
    private let templateManager = CarPlayTemplateManager()
    
    func templateApplicationScene(
        _ templateApplicationScene: CPTemplateApplicationScene,
        didConnect interfaceController: CPInterfaceController
    ) {
        self.interfaceController = interfaceController
        templateManager.configure(with: interfaceController)
        
        let rootTemplate = templateManager.createRootTemplate()
        interfaceController.setRootTemplate(rootTemplate, animated: true) { success, error in
            if let error = error {
                print("CarPlay: Failed to set root template: \(error)")
            }
        }
    }
    
    func templateApplicationScene(
        _ templateApplicationScene: CPTemplateApplicationScene,
        didDisconnect interfaceController: CPInterfaceController
    ) {
        self.interfaceController = nil
        templateManager.disconnect()
    }
    
    func templateApplicationScene(
        _ templateApplicationScene: CPTemplateApplicationScene,
        didSelect navigationAlert: CPNavigationAlert
    ) {
    }
    
    func templateApplicationScene(
        _ templateApplicationScene: CPTemplateApplicationScene,
        didSelect maneuver: CPManeuver
    ) {
    }
}
