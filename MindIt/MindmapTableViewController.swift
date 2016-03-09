
import UIKit
import SwiftDDP
class MindmapTableViewController: UITableViewController , PresenterDelegate, UIAlertViewDelegate {
    
    //MARK:Properties
    var loader: Loader!
    var activityIndicator : UIActivityIndicatorView!
    var strLabel : UILabel!
    
    var presenter: TableViewPresenter!
    var mindmapId: String!
    var timer : NSTimer?
    
    
    private var isFullyDisappeared : Bool = true
    
    //MARK : Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        let logo = UIImage(named: "header")
        let imageView = UIImageView(image:logo)
        self.navigationItem.titleView = imageView
        
        presenter =  TableViewPresenter(viewDelegate: self, meteorTracker: MeteorTracker.getInstance())
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("applicationDidBecomeActive"), name: UIApplicationWillEnterForegroundNotification, object: nil)
        
        self.tableView.rowHeight = UITableViewAutomaticDimension
        self.tableView.estimatedRowHeight = 44
    }
    
    func applicationDidBecomeActive() {
        presenter.connectToServer(mindmapId)
    }

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController!.navigationBar.tintColor = UIColor.orangeColor()
        
        if(isFullyDisappeared == true) {
            isFullyDisappeared = false
            showProgressBar()
            presenter.connectToServer(mindmapId)
        }
        else {
            self.reloadTableView()
        }
    }
    
    
    
    override func viewDidDisappear(animated: Bool) {
        super.viewDidDisappear(animated)
        isFullyDisappeared = true
        presenter.unsubscribe()
        let meteorTracker : MeteorTracker = MeteorTracker.getInstance()
        meteorTracker.subscriptionSuccess = false
    }
    
    func reloadTableView() {
        dispatch_async(dispatch_get_main_queue(), {
            self.tableView.reloadData()
        })
    }
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return presenter.getNodeCount();
    }
    
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cellIdentifier = "NodeViewCell"
        let cell = tableView.dequeueReusableCellWithIdentifier(cellIdentifier, forIndexPath: indexPath) as! NodeViewCell
        
        let node : Node? = presenter.getNodeAt(indexPath.row)
        
        if(node == nil) {
            cell.nodeDataLabel.text = Config.NETWORK_ERROR
        }
        else {
            cell.setData(node!, presenter: presenter)
        }
        return cell
    }
    
    func didConnectSuccessfully() {
        stopProgressBar()
        self.reloadTableView()
    }
    
    func didFailToConnectWithError(error: String) {
        stopProgressBar()
        switch(error) {
        case Config.NETWORK_ERROR  :
            giveAlert(Config.NETWORK_ERROR);
            break
            
        case Config.INVALID_MINDMAP:
            giveAlert(Config.INVALID_MINDMAP)
            break
            
        default:
            giveAlert(Config.UNKNOWN_ERROR)
        }
    }
    
    private func showProgressBar() {
        timer = NSTimer.scheduledTimerWithTimeInterval(NSTimeInterval(Config.MAXIMUM_LOADING_TIME), target: self, selector: Selector("invalidateConnection"), userInfo: nil, repeats: false)
        
        dispatch_async(dispatch_get_main_queue(), {
            self.loader = NSBundle.mainBundle().loadNibNamed("Loader", owner: self, options: nil).first as! Loader
            self.loader.show("Loading Mindmap...")
        })
    }
    
    func invalidateConnection() {
        let meteorTracker : MeteorTracker = MeteorTracker.getInstance()
        if(!(meteorTracker.subscriptionSuccess)){
            self.didFailToConnectWithError(Config.UNKNOWN_ERROR)
        }
        else {
            self.didConnectSuccessfully()
        }
    }
    
    private func stopProgressBar() {
        timer?.invalidate()
        dispatch_async(dispatch_get_main_queue()) {
            self.loader.hide()
        }
    }
    
    func updateChanges() {
            self.reloadTableView()
    }
    
    func giveAlert(errorMessage : String) {
        let meteorTracker : MeteorTracker = MeteorTracker.getInstance()
        meteorTracker.subscriptionSuccess = false
        meteorTracker.unsubscribe()
        
        UIAlertView(title: errorMessage, message: nil, delegate: self, cancelButtonTitle: "OK").show()
    }
    
    func alertView(alertView: UIAlertView, clickedButtonAtIndex buttonIndex: Int) {
        alertView.removeFromSuperview()
        self.navigationController?.popViewControllerAnimated(true)
    }
    
    
}
