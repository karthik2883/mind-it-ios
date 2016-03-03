    
    import SwiftDDP
    
    class MindmapCollection: MeteorCollection<Node> {
        
        var delegate : CollectionDelegate!
        //MARK: Initialisers
        init() {
            super.init(name: "Mindmaps")
        }
        
        
        //MARK : Methods
        override func documentWasAdded(collection: String, id: String, fields: NSDictionary?) {
            super.documentWasAdded(collection, id: id, fields: fields)
            if(MeteorTracker.getInstance().subscriptionSuccess){
                delegate.notifyDocumentChanged(id , fields:  fields)
            }
        
        }
        
        //Delete Will nerver calle as we are only removing id of deleted node from parent's chaildsubtree ( Soft delete)
        override func documentWasRemoved(collection: String, id: String) {
            super.documentWasRemoved(collection, id: id)
            
        }
        
        override func documentWasChanged(collection: String, id: String, fields: NSDictionary?, cleared: [String]?) {
            super.documentWasChanged(collection, id: id, fields: fields, cleared: cleared)
            delegate.notifyDocumentChanged(id , fields:  fields)
        }
    }