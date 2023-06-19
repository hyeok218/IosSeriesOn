import UIKit
import SwiftCSV

class MovieSearchViewController: UIViewController {

    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var CollectionView: UICollectionView!
    @IBOutlet weak var categoryPickerView: UIPickerView!
    
    var movies: [Movie] = []

    override func viewDidLoad() {
        super.viewDidLoad()

        hidesBottomBarWhenPushed = false
        // Do any additional setup after loading the view.
        CollectionView.delegate = self
        CollectionView.dataSource = self
        
        categoryPickerView.delegate = self
        categoryPickerView.dataSource = self
        
        
        
        
    }
    
    func showMovieDetails(with movieID: Int) {
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

extension String {
    func truncateIfNeeded(maxLength: Int) -> String {
        if self.count > maxLength {
            let index = self.index(self.startIndex, offsetBy: maxLength)
            return String(self[..<index]) + "..."
        }
        return self
    }
}

extension MovieSearchViewController: UICollectionViewDataSource{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return movies.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        guard let Moviecell = collectionView.dequeueReusableCell(withReuseIdentifier: "MovieCell", for: indexPath) as? MovieCell else{
            return UICollectionViewCell()
        }
       
        
        let movie = movies[indexPath.item]
        let truncatedOverview = movie.overview.truncateIfNeeded(maxLength: 15)
        let imageSize = CGSize(width: 180, height: 180) // 원하는 이미지 크기 설정
        Moviecell.movieImage.frame.size = imageSize
        Moviecell.movieImage.image = UIImage(named: "poster.jpg")
        Moviecell.movieTitle.text = movie.title
        Moviecell.movieID.text = "\(movie.id)"
        Moviecell.movieOverView.text = truncatedOverview
        return Moviecell
    }
}

extension MovieSearchViewController: UIPickerViewDelegate {
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return SearchData.categories[row]
    }
    
    
    
    
}



extension MovieSearchViewController: UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return SearchData.categories.count
    }
}

class MovieCell: UICollectionViewCell{
    @IBOutlet weak var movieImage: UIImageView!
    
    @IBOutlet weak var movieID: UILabel!
    
    @IBOutlet weak var movieTitle: UILabel!

    @IBOutlet weak var movieOverView: UILabel!
    
    
}

extension MovieSearchViewController: UICollectionViewDelegate{
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let movie = movies[indexPath.item]
            showMovieDetails(with: movie.id)
    }
}


extension MovieSearchViewController: UISearchBarDelegate {
    private func dismissKeyboard() {
        searchBar.resignFirstResponder()
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        dismissKeyboard()
        
        guard let searchWord = searchBar.text, !searchWord.isEmpty else { return }
        
        let selectedCategoryIndex = categoryPickerView.selectedRow(inComponent: 0)
        
        switch selectedCategoryIndex {
        case 0:
            // 영화명으로 검색
            SearchData.searchByMovieTitle(searchWord) { movies in
                let sortedMovies = Array(movies.sorted(by: {
                    if $0.vote_count == $1.vote_count {
                        return $0.vote_average > $1.vote_average
                    } else {
                        return $0.vote_count > $1.vote_count
                    }
                }).prefix(100)).sorted(by: { $0.vote_average > $1.vote_average })

                let searchedMovies = sortedMovies.filter {
                    $0.title.localizedCaseInsensitiveContains(searchWord)
                }

                self.movies = searchedMovies
                DispatchQueue.main.async {
                    self.CollectionView.reloadData()
                }
            }
        
        
        case 1:
            // 배우명으로 검색
            SearchData.searchByActorName(searchWord) { movieIds in
                SearchData.searchByMovieIds(movieIds) { movies in
                    let sortedMovies = Array(movies.sorted(by: {
                        if $0.vote_count == $1.vote_count {
                            return $0.vote_average > $1.vote_average
                        } else {
                            return $0.vote_count > $1.vote_count
                        }
                    }).prefix(100)).sorted(by: { $0.vote_average > $1.vote_average })
                    
                    
                    self.movies = sortedMovies
                    DispatchQueue.main.async { // DispatchQueue.main.async로 감싸줍니다.
                                self.CollectionView.reloadData()
                            }
                }
            }
        default:
            break
        }
    }
}

class SearchData {
    static let categories = ["영화명", "배우명"]
    
    static func searchByMovieTitle(_ term: String, completion: @escaping ([Movie]) -> Void) {
        guard let filePath = Bundle.main.path(forResource: "movies_metadata", ofType: "csv") else {
            print("CSV 오류")
            completion([])
            return
        }

        if let movies = MovieCSV(filePath) {
            let sortedMovies = Array(movies.sorted(by: {
                if $0.vote_count == $1.vote_count {
                    return $0.vote_average > $1.vote_average
                } else {
                    return $0.vote_count > $1.vote_count
                }
            }).prefix(100)).sorted(by: { $0.vote_average > $1.vote_average })
            
            let filteredMovies = sortedMovies.filter { $0.title.lowercased().contains(term.lowercased()) }
            completion(filteredMovies)
        } else {
            completion([])
        }
    }
    
    static func searchByActorName(_ term: String, completion: @escaping ([Int]) -> Void) {
        guard let filePath = Bundle.main.path(forResource: "credits", ofType: "csv") else {
            print("CSV 오류")
            completion([])
            return
        }
        
        if let credits = CreditsCSV(filePath) {
            let filteredCredits = credits.filter { $0.cast.lowercased().contains(term.lowercased()) }
            let movieIds = filteredCredits.map { $0.id }
            completion(movieIds)
        } else {
            completion([])
        }
    }
    
    static func searchByMovieIds(_ movieIds: [Int], completion: @escaping ([Movie]) -> Void) {
        guard let filePath = Bundle.main.path(forResource: "movies_metadata", ofType: "csv") else {
            print("CSV 오류")
            completion([])
            return
        }
        
        if let movies = MovieCSV(filePath) {
            let sortedMovies = Array(movies.sorted(by: {
                if $0.vote_count == $1.vote_count {
                    return $0.vote_average > $1.vote_average
                } else {
                    return $0.vote_count > $1.vote_count
                }
            }).prefix(100)).sorted(by: { $0.vote_average > $1.vote_average })
            
            let filteredMovies = sortedMovies.filter { movieIds.contains($0.id) }
            completion(filteredMovies)
        } else {
            completion([])
        }
    }
    
    static func MovieCSV(_ filePath: String) -> [Movie]? {
        do {
            let csv = try NamedCSV(url: URL(fileURLWithPath: filePath), delimiter: ",")
            var movies: [Movie] = []
            
            let headerRow = csv.header
            
            for row in csv.rows {
                guard let idString = row["id"],
                      let id = Int(idString),
                      let title = row["title"],
                      let overview = row["overview"],
                      let vote_count = row["vote_count"],
                      let vote_average = row["vote_average"]
                else {
                    continue
                }
                
                let movie = Movie(id: id, title: title, overview: overview, vote_count: vote_count,vote_average: vote_average)
                movies.append(movie)
            }
            
            return movies
        } catch {
            print("CSV 오류 발생: \(error)")
            return nil
        }
    }
    
    static func CreditsCSV(_ filePath: String) -> [Credits]? {
        do {
            let csv = try NamedCSV(url: URL(fileURLWithPath: filePath), delimiter: ",")
            var credits: [Credits] = []
            
            let headerRow = csv.header
            
            for row in csv.rows {
                guard let idString = row["id"],
                      let id = Int(idString),
                      let cast = row["cast"]
                else {
                    continue
                }
                
                let credit = Credits(id: id, cast: cast)
                credits.append(credit)
            }
            
            return credits
        } catch {
            print("CSV 오류 발생: \(error)")
            return nil
        }
    }
}

struct Response: Codable {
    let resultCount: Int
    let movies: [Movie]
    
    enum CodingKeys: String, CodingKey {
        case resultCount
        case movies = "results"
    }
}

struct Movie: Codable {
    let id: Int
    let title: String
    let overview: String
    let vote_count: String
    let vote_average: String
    
    enum CodingKeys: String, CodingKey {
        case id
        case title
        case overview
        case vote_count
        case vote_average
    }
}

struct Credits: Codable {
    let id: Int
    let cast: String
    
    enum CodingKeys: String, CodingKey {
        case id
        case cast
    }
}
