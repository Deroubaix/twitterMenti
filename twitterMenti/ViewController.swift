//
//  ViewController.swift
//  twitterMenti
//
//  Created by Marisha Deroubaix on 14/09/18.
//  Copyright © 2018 Marisha Deroubaix. All rights reserved.
//

import UIKit
import SwifteriOS
import CoreML
import SwiftyJSON

class ViewController: UIViewController, UITextFieldDelegate {

  @IBOutlet weak var heightConstraint: NSLayoutConstraint!
  
  @IBOutlet var uiView: UIView!
  @IBOutlet weak var textField: UITextField!
  @IBOutlet weak var sentimentalLabel: UILabel!
  
  let tweetCount = 100
  let sentimentClassifier = TweetSentimentClassifier()
  let swifter = Swifter(consumerKey: "DYC4CRecpm08tVXlnsIddSyZB", consumerSecret: "7m6vx9dNpHRSNlnFYsIvs8Dlr0p4PW4MtaK9D1lKQyzdU322BT")
  
  
  
  
  
  override func viewDidLoad() {
    super.viewDidLoad()
    textField.delegate = self
    
    let tapGesture = UITapGestureRecognizer(target: self, action: #selector(viewTapped))
    uiView.addGestureRecognizer(tapGesture)
    uiView.isUserInteractionEnabled = true
  }
  
  
  @objc func viewTapped(_sender: UITapGestureRecognizer? = nil) {
    textField.endEditing(true)
  }
  


  @IBAction func predictPressed(_ sender: UIButton) {
    
    textField.endEditing(true)
    textField.isEnabled = false
    
    fetchTweets()
  }
  
  func fetchTweets() {
    
    if let searchText = textField.text {
      
      swifter.searchTweet(using: searchText, lang: "en", count: tweetCount, tweetMode: .extended, success: { (results, metadata) in
        var tweets = [TweetSentimentClassifierInput]()
        
        for i in 0..<self.tweetCount {
          
          if let tweet = results[i]["full_text"].string {
            let tweetForClassification = TweetSentimentClassifierInput(text: tweet)
            tweets.append(tweetForClassification)
          }
        }
        self.textField.isEnabled = true
        self.textField.text = ""
        self.makePrediction(with: tweets)
        
        
      }) { (error) in
        print("There was a error with the twitter api request, \(error)")
      }
      
    }
  }
  
  
  func textFieldDidBeginEditing(_ textField: UITextField) {
    UIView.animate(withDuration: 0.5) {
      self.heightConstraint.constant = 308
      self.view.layoutIfNeeded()
    }
  }
  
  func textFieldDidEndEditing(_ textField: UITextField) {
    UIView.animate(withDuration: 0.5) {
      self.heightConstraint.constant = 90
      self.view.layoutIfNeeded()
    }
    
  }

  
  func makePrediction(with tweets: [TweetSentimentClassifierInput]) {
    
    do {
      let predictions = try self.sentimentClassifier.predictions(inputs: tweets)
      var sentimentScore = 0
      for pred in predictions {
        let sentiment = pred.label
        
        if sentiment == "Pos" {
          sentimentScore += 1
        } else if sentiment == "Neg"{
          sentimentScore -= 1
        }
      }
      updateUI(with: sentimentScore)
      
    } catch {
      print("There was an error with making a prediction, \(error)")
    }
  }
  
  func updateUI(with sentimentScore: Int) {
    
    if sentimentScore > 20 {
      self.sentimentalLabel.text = "😍"
    } else if sentimentScore > 10 {
      self.sentimentalLabel.text = "😃"
    } else if sentimentScore > 0 {
      self.sentimentalLabel.text = "🙂"
    } else if sentimentScore == 0 {
      self.sentimentalLabel.text = "😐"
    } else if sentimentScore > -10 {
      self.sentimentalLabel.text = "😕"
    } else if sentimentScore > -20 {
      self.sentimentalLabel.text = "😡"
    } else {
      self.sentimentalLabel.text = "🤮"
    }
  }
  

  

  
  
//  private func textFieldDidEndEditing(_ textField: UITextField) {
//    UIView.animate(withDuration: 0.5) {
//      textField.endEditing(true)
//      self.textFieldConstraint.constant = 50
//      self.view.layoutIfNeeded()
//    }
//  }
  
  
}

