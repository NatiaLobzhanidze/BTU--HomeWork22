//
//  DownloadCell.swift
//  SimpleDownloadTasks
//
//  Created by user200328 on 6/23/21.
//

import UIKit

class ProgressCell: UITableViewCell {

    @IBOutlet weak var taskImageView: UIImageView!
    @IBOutlet weak var taskStateLabel: UILabel!
    
    @IBOutlet weak var progressLine: UIProgressView!
    @IBOutlet weak var subTitle: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
      
        taskImageView.layer.masksToBounds = true
        taskImageView.clipsToBounds = true
        taskImageView.layer.cornerRadius = 5.0
    }

    
    func configure(with task: DownloadTask) {
        taskStateLabel?.text = "\(task.state.description) #\(task.identifier)"
        taskImageView.image = UIImage.randomImage(seed: Int(task.identifier) ?? 0)
        
        
        switch task.state {
        case .pending:
            progressLine.isHidden = true
            subTitle.isHidden = true
            taskImageView.isHidden = true
            
        case .inProgress(let complete):
            progressLine.isHidden = false
            progressLine.progress = Float(Double(complete)/100.0)
            subTitle.isHidden = false
            subTitle.text = "\(complete)%"
            taskImageView.isHidden = false
            
        case .completed:
            progressLine.isHidden = true
            subTitle.isHidden = true
            taskImageView.isHidden = false
        }
    }
    
}

fileprivate extension UIImage {
    static func randomImage(seed: Int) -> UIImage {
        let images = (1...10).map { UIImage(named: "\($0)")! }
        return images[seed % images.count]
    }
}
