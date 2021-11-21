//
//  ViewController.swift
//  SimpleDownloadTasks
//
//  Created by user200328 on 6/23/21.
//

import UIKit

class ViewController: UIViewController {
    
    
    // MARK: - IBOutlets
    @IBOutlet weak var downloadsTableView: UITableView!
    @IBOutlet weak var completedTableView: UITableView!
    
    @IBOutlet weak var greenSwitch: UISwitch!
    @IBOutlet weak var maxTaskLabel: UILabel!
    @IBOutlet weak var maxTaskSlider: UISlider!
    @IBOutlet weak var taskCounterSliderLabel: UILabel!
    @IBOutlet weak var taskCounterSlider: UISlider!
  
    // MARK: - Variables
    var downloadTasks = [DownloadTask]() {
        didSet {
            downloadsTableView.reloadData()
        }
    }
    var completedTasks = [DownloadTask]() {
        didSet {
            completedTableView.reloadData()
        }
    }
    
    var option: SimulationOption!
    
    // MARK: - View Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        downloadsTableView.dataSource = self
        completedTableView.dataSource = self
        self.downloadsTableView.registerNib(class: ProgressCell.self)
        self.completedTableView.registerNib(class: ProgressCell.self)
        option = SimulationOption(jobCount: 10, maxAsyncTasks: 2, isRandomizedTime: true)

        
    }
    

    // MARK: - Task Starter
    @IBAction func startTasks(_ sender: UIButton) {
        
        downloadTasks = []
        completedTasks = []
        
        
    // მოახდინეთ DispatchQueue, DispatchGroup და DispatchSemaphore-ის ინიციალიზაცია
        let dispatchQueue = DispatchQueue(label: "com.alfianlosari.test", qos: .userInitiated, attributes: .concurrent)
        let dispatchGroup = DispatchGroup()
        let dispatchSemaphore = DispatchSemaphore(value: option.maxAsyncTasks)
        
    // შეავსეთ  მასივ(ებ)ი ტასკების სტატუსების მიხედვით
        downloadTasks = (1...option.jobCount).map({ (i) -> DownloadTask in
            let identifier = "\(i)"
            return DownloadTask(identifier: identifier, stateUpdateHandler: { (task) in
                DispatchQueue.main.async { [unowned self] in
                    
                    guard let index = self.downloadTasks.indexOfTaskWith(identifier: identifier) else {
                        return
                    }
                    
                    switch task.state {
                    case .completed:
                        self.downloadTasks.remove(at: index)
                        self.completedTasks.insert(task, at: 0)
                        
                    case .pending, .inProgress(_):
                        guard let cell = self.downloadsTableView.cellForRow(at: IndexPath(row: index, section: 0)) as? ProgressCell else {
                            return
                        }
                        cell.configure(with: task)
                        self.downloadsTableView.beginUpdates()
                        self.downloadsTableView.endUpdates()
                    }
                }
            })
        })
    // დაიწყეთ ჩამოტვირთვა ტასკების
        downloadTasks.forEach {
            $0.startTask(queue: dispatchQueue,
                         group: dispatchGroup,
                         semaphore: dispatchSemaphore,
                         randomizeTime: self.option.isRandomizedTime)
        }
        // აქ აჩვენეთ ალერტი, რომ ყველა ტასკი დასრულებულია
        dispatchGroup.notify(queue: .main) { [unowned self] in
            self.presentAlertWith(title: "Info", message: "All Download tasks has been completed 😋😋😋")
    
            
        }
        
    }
    @IBAction func maxAsyncTasksSliderchanged(_ sender: UISlider) {
        option.maxAsyncTasks = Int(sender.value)
    }
    
    @IBAction func sliderChanged(_ sender: UISlider) {
        option.jobCount = Int(sender.value)
    }
    
    @IBAction func switchChanged(_ sender: UISwitch) {
        option.isRandomizedTime = sender.isOn
    }
    
    private func updateMaxAsyncLabel() {
        maxTaskLabel.text = "\(option.maxAsyncTasks) Max Parallel Running Tasks"
    }
    
    private func updateJobLabel() {
        taskCounterSliderLabel.text = "\(option.jobCount) Tasks"
    }
    
    private func presentAlertWith(title: String , message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        
        present(alert, animated: true)
    }
    
}

// MARK: - UITableView Data Source

// იმპლემენტაცია ამ დელეგატის

extension ViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tableView == downloadsTableView {
            return downloadTasks.count
        } else {
            return completedTasks.count
        }
          
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.deque(ProgressCell.self, for: indexPath)
        let task: DownloadTask
        if tableView == downloadsTableView {
            task = downloadTasks[indexPath.row]
        } else if tableView == completedTableView {
            task = completedTasks[indexPath.row]
        } else {
            fatalError()
        }
        cell.configure(with: task)
        return cell
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if tableView == downloadsTableView {
            return "Download Queue (\(downloadTasks.count))"
        } else if tableView == completedTableView {
            return "Completed (\(completedTasks.count))"
        } else {
            return nil
        }
    }

}
