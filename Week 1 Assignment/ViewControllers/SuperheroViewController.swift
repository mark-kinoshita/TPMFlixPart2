//
//  SuperheroViewController.swift
//  Week 1 Assignment
//
//  Created by Mark Kinoshita on 2/5/18.
//  Copyright © 2018 Mark Kinoshita. All rights reserved.
//

import UIKit

class SuperheroViewController: UIViewController, UICollectionViewDataSource {
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    var movies: [[String: Any]] = []
      var refreshControl: UIRefreshControl!
    override func viewDidLoad() {
        super.viewDidLoad()
        activityIndicator.startAnimating()
        refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(SuperheroViewController.didPullToRefresh(_:)), for: .valueChanged)
        collectionView.dataSource = self
        collectionView.insertSubview(refreshControl, at: 0)
        
        let layout = collectionView.collectionViewLayout as! UICollectionViewFlowLayout
        layout.minimumInteritemSpacing = 5
        layout.minimumLineSpacing = layout.minimumInteritemSpacing
    
        let cellsPerline: CGFloat = 2
        let interItemSpacingTotal = layout.minimumInteritemSpacing * (cellsPerline - 1)
        let width = collectionView.frame.size.width / cellsPerline - interItemSpacingTotal / cellsPerline
        layout.itemSize = CGSize(width: width, height: width * 3 / 2)
        fetchMovies()
    }
    @objc func didPullToRefresh(_ refreshControl: UIRefreshControl){
        fetchMovies()
    }
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return movies.count
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "PosterCell", for: indexPath) as! PosterCell
        let movie = movies[indexPath.item]
        if let posterPathString = movie["poster_path"] as? String{
            let baseURLString = "https://image.tmdb.org/t/p/w500"
            let posterURL = URL(string: baseURLString + posterPathString)!
            cell.posterImageView.af_setImage(withURL: posterURL)
            
        }
        return cell
    }
    func fetchMovies() {
        let url = URL(string: "https://api.themoviedb.org/3/movie/297762/similar?api_key=a07e22bc18f5cb106bfe4cc1f83ad8ed&language=en-US&page=1")!
      
    
        let request = URLRequest(url: url, cachePolicy: .reloadIgnoringLocalCacheData, timeoutInterval: 10)
        let session = URLSession(configuration: .default, delegate: nil, delegateQueue: OperationQueue.main)
        let task = session.dataTask(with: request) { (data, response, error) in
            //This will run when the network request returns
            if let error = error {
                print(error.localizedDescription)
            } else if let data = data {
                let dataDictionary = try! JSONSerialization.jsonObject(with: data, options: []) as! [String: Any]
                let movies = dataDictionary["results"] as! [[String:Any]]
                self.movies = movies
                self.collectionView.reloadData()
           //     self.movies = movies
           //     self.tableView.reloadData()
                self.activityIndicator.stopAnimating()
                self.refreshControl.endRefreshing()
            }
        }
        task.resume()
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let cell = sender as! UICollectionViewCell
        if let indexPath = collectionView.indexPath(for: cell) {
            let movie = movies[indexPath.row]
            let detailViewController = segue.destination as! DetailViewController
            detailViewController.movie = movie
        }
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
