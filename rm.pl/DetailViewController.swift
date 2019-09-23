//
//  DetailViewController.swift
//  rm.pl
//
//  Created by Krzysztof Wolarz on 13/06/2019.
//  Copyright © 2019 Krzysztof Wolarz. All rights reserved.
//

import UIKit
import SwiftSoup
import Kingfisher

class DetailViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate {

    
    @IBOutlet var articleImageView: UIImageView!
    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var dateLabel: UILabel!
    @IBOutlet var textLabel: UILabel!
    @IBOutlet var recemmendedCV: UICollectionView!
    
    let link: String = "http://www.realmadryt.pl/"
    var articleID = String()
    
    var articleImage: UIImage = UIImage()
    var imageURL = String()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        //navigationController?.hidesBarsOnSwipe = true
        
        recemmendedCV.delegate = self
        
        parseTitles(link: link, page: articleID)
        setImage(link: imageURL)
    }
    
    
    override var prefersStatusBarHidden: Bool{
        return true
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 4
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath) as! ReccommendedCVC
        
        cell.testLAbel.text = "\(indexPath.item)"
        return cell
    }
    
    func parseTitles(link: String, page: String){
        if let url = URL(string: "\(link)\(page)"){
            do{
                let html = try String(contentsOf: url, encoding: .utf8)
                do{
                    let newHtml = html.replacingOccurrences(of: "<br />", with: "%%%")
                    let doc: Document = try SwiftSoup.parse(newHtml)
                    let text = try doc.getElementById("intertext1")
                    let title = try doc.select("h2").first()
                    let date = try doc.getElementsByClass("newsinfo")
                    let imgLink: Elements = try doc.select("img[src]")
                    let srcsString: [String?] = imgLink.array().map {try? $0.attr("src").description}
                    imageURL = link + srcsString[2]!
                    
                    let newText = try text!.text().replacingOccurrences(of: "%%% ", with: "\n")
                    let newNewText = newText.replacingOccurrences(of: "%%%", with: "")
                    
                    dateLabel.text = try date.text()
                    textLabel.text = newNewText
                    titleLabel.text = try title?.text()
                    
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
    
    func setImage(link: String){
        let url = URL(string: link)
        //        let data = try? Data(contentsOf: url!)
        //        articleImageView.image = UIImage(data: data!)
        
        articleImageView.kf.setImage(with: url)
    }

}
