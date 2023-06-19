import UIKit
import SwiftCSV
import Foundation
import SwiftSoup

struct Review {
    let author: String
    let reviewText: String
}

class ReviewCell: UICollectionViewCell {
    @IBOutlet weak var authorLabel: UILabel!
    @IBOutlet weak var reviewLabel: UILabel!
}

class DetailViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    var movieID: Int = 359364
    var floatValue: Float = 1
    var movies: [DetailMovie] = []
    var my_count: Int = -1
    var movieaverage: String = ""
    var moviecount: String = ""
    var genre: String?
    var reviews: [Review] = []
    
    @IBOutlet weak var DetailImage: UIImageView!
    @IBOutlet weak var DetailTitle: UILabel!
    @IBOutlet weak var DetailRuntime: UILabel!
    @IBOutlet weak var DetailDate: UILabel!
    @IBOutlet weak var DetailOverview: UILabel!
    
    @IBOutlet var label: UILabel!
    @IBOutlet weak var DetailAverage: UILabel!
    
    @IBOutlet weak var DetailCollection: UICollectionView!
    
    @IBAction func sliderValueChanged(_ sender: UISlider) {
           self.label.text = String(sender.value)
       }
    
    @IBAction func RatingBtn(_ sender: Any) {
            updaterate()
        }
    

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        DetailImage.image = UIImage(named: "DetailPoster.jpg")
        DetailOverview.numberOfLines = 0
        DetailCollection.delegate = self
        DetailCollection.dataSource = self
        loadMovieData()
    }
    
    
    
    
    
  
    
    
    
    
    
    
    func updaterate() {
        if let movie = movies.first(where: { $0.id == movieID }) {
            guard let previousVoteAverage = Float(movieaverage),
                  let previousVoteCount = Float(moviecount) else {
                return
            }
            
            let previousTotal = previousVoteAverage * previousVoteCount
            let newTotal = previousTotal + floatValue
            let newVoteCount = previousVoteCount + 1.0
            let newVoteAverage = newTotal / newVoteCount
            
            DetailAverage.text = String(format: "%.1f", newVoteAverage)
            print(String(format: "%.1f", newVoteAverage))

        }
    }
    
    func crawlIMDBReviews(imdbID: String) {
        print("imdbID : \(imdbID)")
        let urlString = "https://www.imdb.com/title/\(imdbID)/reviews"
        
        guard let url = URL(string: urlString) else {
            print("Invalid URL")
            return
        }
        
        do {
            let html = try String(contentsOf: url)
            let doc = try SwiftSoup.parse(html)
            
            let reviewElements = try doc.select(".review-container")
            
            // 리뷰 배열을 비워줌
            reviews.removeAll()
            
            for reviewElement in reviewElements {
                let reviewText = try reviewElement.select(".content .text").text()
                let author = try reviewElement.select(".display-name-link").text()
                
                print("Review by \(author): \(reviewText)\n")
                
                let review = Review(author: author, reviewText: reviewText)
                reviews.append(review)
            }
            print("reload")
            DispatchQueue.main.async {
                self.DetailCollection.reloadData()
            }
        } catch {
            print("Error: \(error)")
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
            let cellWidth = collectionView.bounds.width // Adjust this value as needed
            let cellHeight: CGFloat = 100 // Adjust this value as needed
            
            return CGSize(width: cellWidth, height: cellHeight)
        }
    
    @IBAction func onDragStarSlider(_ sender: UISlider) {
        let floatValues = floor(sender.value * 10) / 10
        
        let intValue = Int(floor(sender.value))
        
        for index in 0...5 {
            if let starImage = view.viewWithTag(index) as? UIImageView {
                if index <= intValue / 2 {
                    starImage.image = UIImage(named: "Full_Star")
                } else {
                    if (2 * index - intValue) <= 1 {
                        starImage.image = UIImage(named: "Half_Star")
                    } else {
                        starImage.image = UIImage(named: "Empty_Star")
                    }
                }
            }
            self.label?.text = String(format: "%.1f", floatValues).replacingOccurrences(of: "...", with: "")
            print(floatValues)
            floatValue = floatValues
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return reviews.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ReviewCell", for: indexPath) as? ReviewCell else {
            return UICollectionViewCell()
        }
        
        let review = reviews[indexPath.item]
        cell.authorLabel.text = "Author: \(review.author)"
        cell.reviewLabel.text = "Review: \(review.reviewText)"
        
        return cell
    }
    
    func reloadData() {
        loadMovieData()
    }
    
    func loadMovieData() {
        guard let filePath = Bundle.main.path(forResource: "movies_metadata", ofType: "csv") else {
            print("CSV 오류")
            return
        }
        
        if let movies = MovieData.MovieCSV(filePath) {
            self.movies = movies
            if let movie = movies.first(where: { $0.id == movieID }) {
                DetailTitle.text = movie.title
                DetailRuntime.text = "\(movie.runtime)분"
                DetailDate.text = movie.release_date
                DetailOverview.text = movie.overview
                DetailAverage.text = movie.vote_average
                
                let imdbID = movie.imdbId
                crawlIMDBReviews(imdbID: imdbID)
                
                movieaverage = movie.vote_average
                moviecount = movie.vote_count
            }
        }
    }
    
    class MovieData {
        static func MovieCSV(_ filePath: String) -> [DetailMovie]? {
            do {
                let csv = try NamedCSV(url: URL(fileURLWithPath: filePath), delimiter: ",")
                var movies: [DetailMovie] = []
                
                let headerRow = csv.header
                
                for row in csv.rows {
                    guard let idString = row["id"],
                          let id = Int(idString),
                          let title = row["title"],
                          let runtime = row["runtime"],
                          let release_date = row["release_date"],
                          let overview = row["overview"],
                          let vote_average = row["vote_average"],
                          let vote_count = row["vote_count"],
                          let imdbId = row["imdb_id"]
                    else {
                        continue
                    }
                    
                    let movie = DetailMovie(id: id, title: title, runtime: runtime, release_date: release_date, overview: overview, vote_average: vote_average, vote_count: vote_count, imdbId: imdbId)
                    movies.append(movie)
                }
                return movies
            } catch {
                print("CSV 오류 발생: \(error)")
                return nil
            }
        }
    }
}




class SliderTestUISlider: UISlider {

    override func beginTracking(_ touch: UITouch, with event: UIEvent?) -> Bool {
        let width = self.frame.size.width
        let tapPoint = touch.location(in: self)
        let fPercent = tapPoint.x/width
        let nNewValue = self.maximumValue * Float(fPercent)
        if nNewValue != self.value {
            self.value = nNewValue
        }
        return true
    }
}

class StarRatingUISlider: UISlider {

    override func beginTracking(_ touch: UITouch, with event: UIEvent?) -> Bool {
        let width = self.frame.size.width
        let tapPoint = touch.location(in: self)
        let fPercent = tapPoint.x/width
        let nNewValue = self.maximumValue * Float(fPercent)
        if nNewValue != self.value {
            self.value = nNewValue
        }
        return true
    }
}

struct DetailMovie {
    let id: Int
    let title: String
    let runtime: String
    let release_date: String
    let overview: String
    let vote_average: String
    let vote_count: String
    let imdbId: String
}
