//
//  BusinessCardTVC.swift
//  VirtualBusinessCard
//
//  Created by Arek Otto on 04/05/2020.
//  Copyright © 2020 Arek Otto. All rights reserved.
//
/*
import UIKit
import CoreMotion

class BusinessCardTVC: UITableViewController {

    let motionManager = CMMotionManager()

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.separatorStyle = .none
        tableView.register(BusinessCardCell.self, forCellReuseIdentifier: "cell")
    }


    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        motionManager.deviceMotionUpdateInterval = 0.1
        motionManager.startDeviceMotionUpdates(to: OperationQueue.main) { (motion, error) in
            self.tableView.visibleCells.map {$0 as! BusinessCardCell}.forEach {
                $0.sceneView.updateMotionData(motion: motion, error: error)
            }
        }
    }

    // MARK: - Table view data source

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 50
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! BusinessCardCell

        cell.selectionStyle = .none
        return cell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.beginUpdates()
        (tableView.cellForRow(at: indexPath) as! BusinessCardCell).isExpanded.toggle()
        tableView.endUpdates()
//        tableView.reloadRows(at: [indexPath], with: .automatic)
    }

    override func tableView(_ tableView: UITableView, didEndDisplaying cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        (cell as! BusinessCardCell).sceneView.scene.isPaused = true
    }

    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        (cell as! BusinessCardCell).sceneView.scene.isPaused = false
    }

    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        (tableView.cellForRow(at: indexPath) as? BusinessCardCell)?.isExpanded == true ? 250 : 100
    }
}

class BusinessCardCell: UITableViewCell {

    let sceneView = BusinessCardSceneView(isAcceptingMoves: false)
    var topConstr: NSLayoutConstraint!

    var isExpanded = false {
        didSet {
            if isExpanded {
                topConstr.constant = 16
                sceneView.tiltStraight()
            } else {
                topConstr.constant = -20
                sceneView.tiltSideways()
            }
            UIView.animate(withDuration: 0.4) {
                self.layoutIfNeeded()
            }
        }
    }

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        clipsToBounds = true
        contentView.addSubview(sceneView)
        sceneView.translatesAutoresizingMaskIntoConstraints = false

        backgroundColor = .clear

        NSLayoutConstraint.activate([
            sceneView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            sceneView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
//            sceneView.heightAnchor.constraint(equalToConstant: 220)
        ])

        topConstr = sceneView.topAnchor.constraint(equalTo: topAnchor, constant: -20)
        topConstr.isActive = true

    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}
*/
