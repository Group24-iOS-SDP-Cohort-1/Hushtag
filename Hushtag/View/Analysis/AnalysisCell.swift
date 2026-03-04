import UIKit

class AnalysisCell: UICollectionViewCell {

    @IBOutlet weak var analysisValue: UILabel!
    @IBOutlet weak var analysisType: UILabel!
    @IBOutlet weak var changeLabel: UILabel!
    @IBOutlet weak var sfSymbol: UIImageView!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        applyLiquidGlassEffect()
    }
    
    func configure(
        metric: AnalysisMetric,
        data: Int
    ) {

        analysisValue.text = "\(data.formattedCount())"
        var title: String!
        switch metric {

        case .views:
            title = "Views"
            //sfSymbol.image =
              //  UIImage(systemName: "eye.fill")

        case .likes:
            title = "Likes"
            //sfSymbol.image =
               // UIImage(systemName: "hand.thumbsup.fill")

        case .watchTime:
            title = "Watch Time"
            //sfSymbol.image =
               // UIImage(systemName: "clock.fill")
            
        case .subscribers:
            title = "Subscribers"
            //sfSymbol.image =
               // UIImage(systemName: "clock.fill")
        }
        
        analysisType.text = title

        //  No comparison data yet
        changeLabel.text = ""
        changeLabel.textColor = .secondaryLabel
    }
    
    
}
