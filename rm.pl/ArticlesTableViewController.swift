//
//  ArticlesTableViewController.swift
//  rm.pl
//
//  Created by Krzysztof Wolarz on 07/06/2019.
//  Copyright © 2019 Krzysztof Wolarz. All rights reserved.
//

import UIKit
import SwiftSoup

class ArticlesTableViewController: UITableViewController {
    
    var articles = [String]()
    var index = [String]()
    var newsInfo = [String]()
    
    let link = "http://www.realmadryt.pl/index.php?co=aktualnosci&strona="
    var strona = 1
    
    var fetchingMore = false

    override func viewDidLoad() {
        super.viewDidLoad()
        parseTitles(link: link, page: strona)
    }

    // MARK: - Table view data source
    @IBAction func refreshPulled(_ sender: UIRefreshControl) {
        
//        DispatchQueue.main.async {
//            self.articles.removeAll()
//            self.index.removeAll()
//            self.newsInfo.removeAll()
//            self.strona = 1
//            self.parseTitles(link: self.link, page: self.strona)
//        }

//        DispatchQueue.main.asyncAfter(deadline: .now(), execute: {
//            self.articles.removeAll()
//            self.index.removeAll()
//            self.newsInfo.removeAll()
//            self.strona = 1
//            self.parseTitles(link: self.link, page: self.strona)
//        })
        
        articles.removeAll()
        index.removeAll()
        newsInfo.removeAll()
        strona = 1
        parseTitles(link: self.link, page: self.strona)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5, execute: {
            sender.endRefreshing()
        })

        
        self.tableView.reloadData()
    }
    
    override var prefersStatusBarHidden: Bool{
        return true
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return articles.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        
        if articles[indexPath.row].contains("Oficjalnie:"){
            cell.textLabel?.font = UIFont.boldSystemFont(ofSize: 23.0)
        } else {
            cell.textLabel?.font = UIFont.systemFont(ofSize: 20.0)
        }
        cell.textLabel?.text = articles[indexPath.row]
        
        cell.detailTextLabel?.font = UIFont.systemFont(ofSize: 13.0)
        cell.detailTextLabel?.text = newsInfo[indexPath.row]

        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let articleVC = storyboard?.instantiateViewController(withIdentifier: "Detail") as? DetailViewController{
            articleVC.articleID = index[indexPath.row]
            navigationController?.pushViewController(articleVC, animated: true)
        }
    }
    
    
    func parseTitles(link: String, page: Int){
        if let url = URL(string: "\(link)\(page)"){
            do{
                let html = try String(contentsOf: url)
                do{
                    let doc: Document = try SwiftSoup.parse(html)
                    var title: [Element] = try doc.select("h2").array()
                    var articleURL: [Element] = try doc.getElementsByClass("bda").array()
                    var articleDate: [Element] = try doc.getElementsByClass("newsinfo").array()
                    
                    
                    for i in 0...title.count - 1{
//                        if try title[i].text().contains("Oficjalnie: "){
//                            print(try title[i].text())
//                        }
                        articles.append(try title[i].text())
                        index.append(try articleURL[i].attr("href"))
                        newsInfo.append(try articleDate[i].text())
                    }
                    
                    strona += 1
                    //print(strona)
                    if strona < 10{
                        parseTitles(link: link, page: strona)
                    }
                    
                } catch Exception.Error(type: nil, Message: let message){
                    print(message)
                } catch{
                    print("error")
                }
            } catch{
                print("Can't Connect")
            }
        } else{
            print("Empty URL")
        }
    }
    
    
    override func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let offsetY = scrollView.contentOffset.y
        let contentHeight = scrollView.contentSize.height
        //print("Offset: \(offsetY), coontentHeight: \((contentHeight - scrollView.frame.height * 3))")
        
        if abs(offsetY) > abs(contentHeight - scrollView.frame.height * 3){
            if !fetchingMore{
                beginFetching()
            }
        }
    }
    
    func beginFetching(){
        fetchingMore = true
        //print("beginFetching")
        
        DispatchQueue.global().asyncAfter(deadline: .now() + 0.5, execute: {
            for _ in 0...5{
                self.parseTitles(link: self.link, page: self.strona)
            }
            self.fetchingMore = false
        })
        tableView.reloadData()
    }
}
