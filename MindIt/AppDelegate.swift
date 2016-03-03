
import UIKit
import SwiftDDP

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
    private var isConnected : Bool = false
    
    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        
        connectToServer( { () -> Void in
            
        })
        
        return true
    }
    
    
    private func connectToServer(callback: ()-> Void) {
        print("Calback : " , callback)
        if(isConnected == true) {
            callback()
            return
        }
        else {
            Meteor.client.logLevel = .Debug
            let meteorTracker : MeteorTracker = MeteorTracker.getInstance()
            
            if(meteorTracker.isConnectedToNetwork()) {
                Meteor.connect(Config.URL) {
                    self.isConnected = true
                    meteorTracker.connectToServer(Config.FIRST_CONNECT)
                    callback()
                }
            }
        }
    }
    
    
    func application(app: UIApplication, openURL url: NSURL, options: [String : AnyObject]) -> Bool {
        connectToServer({()-> Void in
            self.window = UIWindow(frame: UIScreen.mainScreen().bounds)
            let mainStoryboard : UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
            let navigationVC = mainStoryboard.instantiateInitialViewController() as! UINavigationController
            
            let id : String = self.getIdFromURL(String(url))
            
            //Render MindmapTableView
            if(id != "") {
                let mindmapTableViewController : MindmapTableViewController = mainStoryboard.instantiateViewControllerWithIdentifier("MindmapTableView") as! MindmapTableViewController
                
                navigationVC.pushViewController(mindmapTableViewController, animated: false)
                mindmapTableViewController.mindmapId = id
            }
            self.window?.rootViewController = navigationVC
            self.window?.makeKeyAndVisible()
        })
        return true
    }
    
    
    private func getIdFromURL(url : String) -> String {
        let id : String = url.stringByReplacingOccurrencesOfString("mindit.xyz://create/", withString: "")
        return id
    }
    
    func applicationDidBecomeActive(application: UIApplication) {
        print("did Become Active");
        let mindmapId : String? = MeteorTracker.getInstance().mindmapId
        if(mindmapId != nil){
            Meteor.subscribe("mindmap",params: [mindmapId!])
            
        }
    }
    
    func applicationDidEnterBackground(application: UIApplication) {
     Meteor.unsubscribe("mindmap")
     MeteorTracker.getInstance().subscriptionSuccess = false;
    }
}
