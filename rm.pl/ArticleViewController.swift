//
//  ArticleViewController.swift
//  rm.pl
//
//  Created by Krzysztof Wolarz on 08/06/2019.
//  Copyright © 2019 Krzysztof Wolarz. All rights reserved.
//

import UIKit
import SwiftSoup
import Kingfisher

class ArticleViewController: UIViewController {
    
    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var articleImageView: UIImageView!
    @IBOutlet var articleText: UITextView!
    
    let link: String = "http://www.realmadryt.pl/"
    var articleID = String()
    
    var articleImage: UIImage = UIImage()
    var imageURL = String()

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.hidesBarsOnSwipe = true

        // Do any additional setup after loading the view.
        articleText.text = articleID
        
        parseTitles(link: link, page: articleID)
        setImage(link: imageURL)
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
                    let imgLink: Elements = try doc.select("img[src]")
                    let srcsString: [String?] = imgLink.array().map {try? $0.attr("src").description}
                    imageURL = link + srcsString[2]!
                    
                    let newText = try text!.text().replacingOccurrences(of: "%%% ", with: "\n")
                    let newNewText = newText.replacingOccurrences(of: "%%%", with: "")
                    
                    articleText.text = newNewText
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
