import UIKit

class MovieCell: UICollectionViewCell {
    let imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        // 추가적인 설정을 여기에 추가하세요
        return imageView
    }()

    let titleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.boldSystemFont(ofSize: 16)
        label.textColor = .black
        // 추가적인 설정을 여기에 추가하세요
        return label
    }()
    
    let idLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 14)
        label.textColor = .gray
        // 추가적인 설정을 여기에 추가하세요
        return label
    }()

    let overviewLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 14)
        label.textColor = .gray
        // 추가적인 설정을 여기에 추가하세요
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupViews()
    }
    
    private func setupViews() {
        // 서브뷰를 추가하고 제약조건을 설정합니다
        addSubview(imageView)
        addSubview(titleLabel)
        addSubview(overviewLabel)
        
        // 각 서브뷰의 제약조건을 설정합니다
        // 예시로는 각각 이미지뷰, 제목 레이블, 개요 레이블의 위치와 크기를 조정합니다
    }
}
