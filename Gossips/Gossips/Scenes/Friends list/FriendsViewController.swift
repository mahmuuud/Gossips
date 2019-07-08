//
//  FriendsViewController.swift
//  Gossips
//
//  Created by mahmoud mohamed on 7/8/19.
//  Copyright © 2019 Robusta. All rights reserved.
//

import UIKit

class FriendsViewController: UIViewController {

    @IBOutlet weak var friendsListTableView: UITableView!
    let friendCellNib = UINib(nibName: "FriendsListTableViewCell", bundle: nil)
    let friendCellReuseId = "FriendsListTableViewCell"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configViews()
    }
    
    func configViews(){
        friendsListTableView.register(friendCellNib, forCellReuseIdentifier: friendCellReuseId)
        setupNavBar()
    }
    
    func setupNavBar(){
        navigationItem.title = "Chats"
//        self.navigationController?.navigationBar.backgroundColor = .darkGray
        self.navigationController?.navigationBar.prefersLargeTitles = true
        let newChatBarButton = UIBarButtonItem(image:#imageLiteral(resourceName: "+") , style: .plain, target: self, action: nil)
        newChatBarButton.tintColor = UIColor(red: 233.0 / 255.0, green: 69.0 / 255.0, blue: 126.0 / 255.0, alpha: 1.0)
        self.navigationController?.navigationBar.barTintColor = .black
        let textAttributes = [NSAttributedString.Key.foregroundColor:UIColor.white]
        self.navigationController?.navigationBar.largeTitleTextAttributes = textAttributes
        self.navigationController?.navigationBar.barStyle = .black
        self.navigationItem.rightBarButtonItem = newChatBarButton
    }
    
    
}

extension FriendsViewController:UITableViewDataSource,UITableViewDelegate{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: friendCellReuseId,for: indexPath)
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return CGFloat(tableView.frame.height/7)
    }
    
}


