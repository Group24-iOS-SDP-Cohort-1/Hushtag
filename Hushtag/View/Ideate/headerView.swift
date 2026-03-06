import UIKit

class HeaderView: UICollectionReusableView {

    @IBOutlet weak var headerView: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
    }
    func configureHeader(text:String){
        headerView.text = text
    }
}
