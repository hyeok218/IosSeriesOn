import UIKit
import SwiftCSV

class MainViewController: UIViewController {
    
    @IBOutlet weak var mainCollectionView: UICollectionView!
    @IBOutlet weak var genreCollectionView: UICollectionView!
    @IBOutlet weak var genre2CollectionView: UICollectionView!
    @IBOutlet weak var genre3CollectionView: UICollectionView!
    @IBOutlet weak var categorySegmentedControl: UISegmentedControl!
    
    @IBOutlet weak var genreText:UILabel!
    @IBOutlet weak var genre2Text:UILabel!
    @IBOutlet weak var genre3Text:UILabel!
    
    @IBOutlet weak var MoviePopupButton: UIButton!
    
    var movies: [AllMovie] = []
    var animationMovies: [AllMovie] = []
    var dramaMovies: [AllMovie] = []
    var horrorMovies: [AllMovie] = []
    var isMovieCount: Bool = false
    
    func setPopupButton() {
        let optionClosure: (UIAction) -> Void = { [weak self] action in
            guard let self = self else { return }

            if action.title == "평균 평점순" {
                self.isMovieCount = false
            } else if action.title == "평가 갯수" {
                self.isMovieCount = true
            }

            self.loadData()
        }

        let menu = UIMenu(children: [
            UIAction(title: "평균 평점순", state: isMovieCount ? .off : .on, handler: optionClosure),
            UIAction(title: "평가 갯수", state: isMovieCount ? .on : .off, handler: optionClosure)
        ])

        MoviePopupButton.menu = menu
        MoviePopupButton.showsMenuAsPrimaryAction = true
        
        
        
        MoviePopupButton.addTarget(self, action: #selector(MoviePopupBtn(_:)), for: .touchUpInside)
    }
        
        
        @IBAction func MoviePopupBtn(_ sender: UIButton) {
            let alertController = UIAlertController(title: "Sort By", message: nil, preferredStyle: .actionSheet)

            let voteAverageAction = UIAlertAction(title: "평균 평점순", style: .default) { (_) in
                self.isMovieCount = false
                self.loadData()
                print("isMovieCount : \(self.isMovieCount)")
            }

            let voteCountAction = UIAlertAction(title: "평가 갯수", style: .default) { (_) in
                self.isMovieCount = true
                self.loadData()
                print("isMovieCount : \(self.isMovieCount)")
            }

            alertController.addAction(voteAverageAction)
            alertController.addAction(voteCountAction)

            alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))

            
            alertController.popoverPresentationController?.sourceView = sender

            
            if isMovieCount {
                alertController.preferredAction = voteCountAction
            } else {
                alertController.preferredAction = voteAverageAction
            }

            
            if let preferredAction = alertController.preferredAction, alertController.actions.contains(preferredAction) {
                present(alertController, animated: true, completion: nil)
            } else {
                print("Invalid preferred action")
            }
        }
    
    
    

    override func viewDidLoad() {
        super.viewDidLoad()

        mainCollectionView.delegate = self
        mainCollectionView.dataSource = self
        genreCollectionView.delegate = self
        genreCollectionView.dataSource = self
        genre2CollectionView.delegate = self
        genre2CollectionView.dataSource = self
        genre3CollectionView.delegate = self
        genre3CollectionView.dataSource = self

        loadData()
        setPopupButton()
        
        categorySegmentedControl.addTarget(self, action: #selector(categorySegmentedControlValueChanged(_:)), for: .valueChanged)
                categorySegmentedControl.selectedSegmentIndex = 0
                showCollectionView(forIndex: 0)
    }
    
    

    func loadData() {
        guard let filePath = Bundle.main.path(forResource: "movies_metadata", ofType: "csv") else {
            print("CSV 오류")
            return
        }
        if(isMovieCount == false){
            if let movies = MovieData.MovieCSV(filePath) {
                
                let sortedMovies = movies.sorted(by: {
                    if $0.vote_count == $1.vote_count {
                        return $0.vote_average > $1.vote_average
                    } else {
                        return $0.vote_count > $1.vote_count
                    }
                })
                let topMovies = Array(sortedMovies.prefix(100)).sorted(by: { $0.vote_average > $1.vote_average })
                //print(topMovies)
                self.movies = Array(topMovies.prefix(20))
                
                // "animation" 장르의 영화 중 vote_count가 가장 높은 20개의 영화를 필터링하여 animationMovies 배열에 저장
                self.animationMovies = Array(topMovies.filter { movie in
                    movie.genres.contains { genre in
                        return genre.contains("Animation")
                    }
                }.prefix(20))
                
                // "drama" 장르의 영화 중 vote_count가 가장 높은 20개의 영화를 필터링하여 dramaMovies 배열에 저장
                self.dramaMovies = Array(topMovies.filter { movie in
                    movie.genres.contains { genre in
                        return genre.contains("Drama")
                    }
                }.prefix(20))
                
                // "horror" 장르의 영화 중 vote_count가 가장 높은 20개의 영화를 필터링하여 horrorMovies 배열에 저장
                self.horrorMovies = Array(topMovies.filter { movie in
                    movie.genres.contains { genre in
                        return genre.contains("Horror")
                    }
                }.prefix(20))
            } else {
                print("CSV 데이터 로드 오류")
            }
            mainCollectionView.reloadData()
            genreCollectionView.reloadData()
            genre2CollectionView.reloadData()
            genre3CollectionView.reloadData()
        }
        else if(isMovieCount == true){
            if let movies = MovieData.MovieCSV(filePath) {
                
                let sortedMovies = movies.sorted(by: {
                    if $0.vote_count == $1.vote_count {
                        return $0.vote_average > $1.vote_average
                    } else {
                        return $0.vote_count > $1.vote_count
                    }
                })
                let topMovies = Array(sortedMovies.prefix(100))
                
                //print(topMovies)
                self.movies = Array(topMovies.prefix(20))
                
                // "animation" 장르의 영화 중 vote_count가 가장 높은 20개의 영화를 필터링하여 animationMovies 배열에 저장
                self.animationMovies = Array(topMovies.filter { movie in
                    movie.genres.contains { genre in
                        return genre.contains("Animation")
                    }
                }.prefix(20))
                
                // "drama" 장르의 영화 중 vote_count가 가장 높은 20개의 영화를 필터링하여 dramaMovies 배열에 저장
                self.dramaMovies = Array(topMovies.filter { movie in
                    movie.genres.contains { genre in
                        return genre.contains("Drama")
                    }
                }.prefix(20))
                
                // "horror" 장르의 영화 중 vote_count가 가장 높은 20개의 영화를 필터링하여 horrorMovies 배열에 저장
                self.horrorMovies = Array(topMovies.filter { movie in
                    movie.genres.contains { genre in
                        return genre.contains("Horror")
                    }
                }.prefix(20))
            } else {
                print("CSV 데이터 로드 오류")
            }
        }
        mainCollectionView.reloadData()
        genreCollectionView.reloadData()
        genre2CollectionView.reloadData()
        genre3CollectionView.reloadData()
    }
    
    @objc func categorySegmentedControlValueChanged(_ sender: UISegmentedControl) {
            let selectedIndex = sender.selectedSegmentIndex
            showCollectionView(forIndex: selectedIndex)
        }
        
        func showCollectionView(forIndex index: Int) {
            genreText.isHidden = index != 0
            genreCollectionView.isHidden = index != 0
            genre2Text.isHidden = index != 1
            genre2CollectionView.isHidden = index != 1
            genre3Text.isHidden = index != 2
            genre3CollectionView.isHidden = index != 2
        }
    
}



extension MainViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView == mainCollectionView {
            return movies.count
        } else if collectionView == genreCollectionView {
            return animationMovies.count
        } else if collectionView == genre2CollectionView {
            return dramaMovies.count
        } else if collectionView == genre3CollectionView {
            return horrorMovies.count
        }
        return 0
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if collectionView == mainCollectionView {
            guard let mainCell = collectionView.dequeueReusableCell(withReuseIdentifier: "MainCell", for: indexPath) as? MainCell else {
                return UICollectionViewCell()
            }

            let movie = movies[indexPath.item]
            let imageSize = CGSize(width: 180, height: 180) // 원하는 이미지 크기 설정
            mainCell.movieImage.frame.size = imageSize
            mainCell.movieImage.image = UIImage(named: "poster.jpg")
            mainCell.movieTitle.text = movie.title

            return mainCell
        } else if collectionView == genreCollectionView {
            guard let genreCell = collectionView.dequeueReusableCell(withReuseIdentifier: "GenreCell1", for: indexPath) as? GenreCell1 else {
                return UICollectionViewCell()
            }
            
            let movie = animationMovies[indexPath.item]
            let imageSize = CGSize(width: 180, height: 180)
            genreCell.movieImage1.frame.size = imageSize
            genreCell.movieImage1.image = UIImage(named: "poster.jpg")
            genreCell.movieTitle1.text = movie.title
            
            return genreCell
        } else if collectionView == genre2CollectionView {
            guard let genreCell2 = collectionView.dequeueReusableCell(withReuseIdentifier: "GenreCell2", for: indexPath) as? GenreCell2 else {
                return UICollectionViewCell()
            }
            
            let movie = dramaMovies[indexPath.item]
            let imageSize = CGSize(width: 180, height: 180)
            genreCell2.movieImage2.frame.size = imageSize
            genreCell2.movieImage2.image = UIImage(named: "poster.jpg")
            genreCell2.movieTitle2.text = movie.title
            
            return genreCell2
        } else if collectionView == genre3CollectionView {
            guard let genreCell3 = collectionView.dequeueReusableCell(withReuseIdentifier: "GenreCell3", for: indexPath) as? GenreCell3 else {
                return UICollectionViewCell()
            }
            
            let movie = horrorMovies[indexPath.item]
            let imageSize = CGSize(width: 180, height: 180)
            genreCell3.movieImage3.frame.size = imageSize
            genreCell3.movieImage3.image = UIImage(named: "poster.jpg")
            genreCell3.movieTitle3.text = movie.title
            
            return genreCell3
        }
        
        return UICollectionViewCell()
    }
    
}

extension MainViewController:UICollectionViewDelegate{
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let movie: AllMovie
            let genre: String
            if collectionView == mainCollectionView {
                movie = movies[indexPath.item]
                
            } else if collectionView == genreCollectionView {
                movie = animationMovies[indexPath.item]
                
            } else if collectionView == genre2CollectionView {
                movie = dramaMovies[indexPath.item]
                
            } else if collectionView == genre3CollectionView {
                movie = horrorMovies[indexPath.item]
                
            } else {
                return
            }
        showDetailViewController(with: movie.id)
    }

    func showDetailViewController(with movieID: Int) {
        // 원하는 대상 ViewController의 식별자로 변경
            guard let movieDetailsVC = tabBarController?.viewControllers?.first(where: { $0 is DetailViewController }) as? DetailViewController else {
                return
            }
            
            // MovieDetailsViewController에 전달할 데이터 설정
            movieDetailsVC.movieID = movieID
            
            // 대상 ViewController로 이동
            tabBarController?.selectedViewController = movieDetailsVC
        // 데이터 로드를 위해 reloadData 호출
            movieDetailsVC.reloadData()

        }
}

extension MainViewController:
    UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if collectionView == genreCollectionView || collectionView == genre2CollectionView || collectionView == genre3CollectionView {
            let cellWidth = collectionView.bounds.width -   0
            let cellHeight = collectionView.bounds.height - 20
            return CGSize(width: cellWidth, height: cellHeight)
        }
        return CGSize(width: 180, height: 180)
    }
}

class MainCell: UICollectionViewCell {
    @IBOutlet weak var movieImage: UIImageView!
    @IBOutlet weak var movieTitle: UILabel!
}

class GenreCell1: UICollectionViewCell {
    @IBOutlet weak var movieImage1: UIImageView!
    @IBOutlet weak var movieTitle1: UILabel!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }

    private func commonInit() {
        // 초기화 작업 수행
    }
}

class GenreCell2: UICollectionViewCell {
    @IBOutlet weak var movieImage2: UIImageView!
    @IBOutlet weak var movieTitle2: UILabel!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }

    private func commonInit() {
        // 초기화 작업 수행
    }
}

class GenreCell3: UICollectionViewCell {
    @IBOutlet weak var movieImage3: UIImageView!
    @IBOutlet weak var movieTitle3: UILabel!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    
    private func commonInit() {
        // 초기화 작업 수행
    }

    
}

class MovieData {
    static func MovieCSV(_ filePath: String) -> [AllMovie]? {
        do {
            let csv = try NamedCSV(url: URL(fileURLWithPath: filePath), delimiter: ",")
            var movies: [AllMovie] = []

            let headerRow = csv.header

            for row in csv.rows {
                guard let idString = row["id"],
                      let id = Int(idString),let title = row["title"],
                      let genresString = row["genres"],
                      let vote_count = row["vote_count"],
                      let vote_average =
                        row["vote_average"]
                else {
                    continue
                }
                let genres = genresString.components(separatedBy: ",")
                
                //print("장르 : \(genres)")
                let movie = AllMovie(id:id, title: title, vote_count: vote_count, genres: genres,vote_average: vote_average)
                movies.append(movie)
            }
            return movies
        } catch {
            print("CSV 오류 발생: \(error)")
            return nil
        }
    }
}

struct AllMovie {
    let id:Int
    let title: String
    let vote_count: String
    let genres: [String]
    let vote_average: String
}
