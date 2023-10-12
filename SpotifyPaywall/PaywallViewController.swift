//
//  PaywallViewController.swift
//  SpotifyPaywall
//
//  Created by tony yun on 2023/10/12.
//

import UIKit

// https://developer.spotify.com/documentation/general/design-and-branding/#using-our-logo
// https://developer.apple.com/documentation/uikit/nscollectionlayoutsectionvisibleitemsinvalidationhandler
// 과제: 아래 애플 샘플 코드 다운받아서 돌려보기  https://developer.apple.com/documentation/uikit/views_and_controls/collection_views/implementing_modern_collection_views

class PaywallViewController: UIViewController {

    @IBOutlet weak var pageControl: UIPageControl!
    @IBOutlet weak var collectionView: UICollectionView!
    
    let bannerInfos: [BannerInfo] = BannerInfo.list
    // 배너 별로 쓰일 배경색상
    let colors: [UIColor] = [.systemPurple, .systemOrange, .systemPink, .systemRed]
    
    typealias Item = BannerInfo
    enum Section {
        case main
    }
       
    var datasource: UICollectionViewDiffableDataSource<Section, Item>!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
//        if let flowlayout = collectionView.collectionViewLayout as? UICollectionViewFlowLayout {
//            flowlayout.estimatedItemSize = .zero
//        }
        
        // page control의 점을 총 몇개 보여줄 것인지
        pageControl.numberOfPages = bannerInfos.count
        
        // presentation: diffable datasource
        datasource = UICollectionViewDiffableDataSource<Section, Item>(collectionView: collectionView, cellProvider: { collectionView, indexPath, itemIdentifier in
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "BannerCell", for: indexPath) as? BannerCell else {
                return nil
            }
            cell.configure(itemIdentifier)
            
            // 배경색 설정
            cell.backgroundColor = self.colors[indexPath.item]
            return cell
        })
        
        // data: snapshot
        var snapshot = NSDiffableDataSourceSnapshot<Section, Item>()
        snapshot.appendSections([.main])
        snapshot.appendItems(bannerInfos, toSection: .main)
        datasource.apply(snapshot)
        
        // layout: compositional layout
        collectionView.collectionViewLayout = layout()
        
        // 수평이어도 위아래 스크롤 가능 현상 방지
        collectionView.alwaysBounceVertical = false
        
    }
    private func layout() -> UICollectionViewCompositionalLayout {
        
        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .fractionalHeight(1))
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(0.8), heightDimension: .absolute(200))
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
        let section = NSCollectionLayoutSection(group: group)
        
        // 방향을 수평으로 설정하기, 
        // .continuous는 스르륵 스크롤, .groupPaging은 왼쪽에 맞춰서 촥촥 스크롤
        section.orthogonalScrollingBehavior = .groupPagingCentered
        section.interGroupSpacing = 20
        
        // page control 계산
        section.visibleItemsInvalidationHandler = { (item, offset, env) in
            // 상황에 따라 다르게 계산해야 할수도 있음.
            let index = Int((offset.x / env.container.contentSize.width).rounded(.up))
            self.pageControl.currentPage = index
        }
        
        let layout = UICollectionViewCompositionalLayout(section: section)
        return layout
    }
}

