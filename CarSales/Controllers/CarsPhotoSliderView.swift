//
//  CarsPhotoSliderView.swift
//  CarSales
//
//  Created by Vikas Bawa on 23/06/22.
//  Copyright © 2022 Vikas Bawa. All rights reserved.
//

import UIKit

class CarsPhotoSliderView: UIView {
    @IBOutlet var contentView       : UIView!
    @IBOutlet var scrollView        : UIScrollView!
    @IBOutlet var pageControl       : UIPageControl!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    
    func configure(_ arrImages: NSArray, _ frame: CGRect) {
        scrollView.frame = frame
        
        let scrollViewWidth: CGFloat = scrollView.frame.width
        let scrollViewHeight: CGFloat = scrollView.frame.height
        
        for (index, imageSource) in arrImages.enumerated() {
            let imageView = UIImageView(frame: CGRect(x: scrollViewWidth * CGFloat(index),y: 0, width: scrollViewWidth, height: scrollViewHeight))
            imageView.setImageFromUrl(ImageURL: imageSource as! String)
            imageView.contentMode = .scaleAspectFill
            imageView.clipsToBounds = true
            scrollView.addSubview(imageView)
        }
        
        scrollView.contentSize = CGSize(width: scrollView.frame.width * CGFloat(arrImages.count), height: scrollView.frame.height)
        pageControl.numberOfPages = arrImages.count
    }
    
    private func commonInit() {
        Bundle.main.loadNibNamed(String(describing: CarsPhotoSliderView.self), owner: self, options: nil)
        addSubview(contentView)
        contentView.frame = self.bounds
        contentView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
    }
    
    @IBAction func pageControlTap(_ sender: Any?) {
        guard let pageControl: UIPageControl = sender as? UIPageControl else {
            return
        }
        
        scrollToIndex(index: pageControl.currentPage)
    }
    
    private func scrollToIndex(index: Int) {
        let pageWidth: CGFloat = scrollView.frame.width
        let slideToX: CGFloat = CGFloat(index) * pageWidth
        
        scrollView.scrollRectToVisible(CGRect(x: slideToX, y:0, width:pageWidth, height:scrollView.frame.height), animated: true)
    }
}

extension CarsPhotoSliderView: UIScrollViewDelegate {
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView){
        let pageWidth:CGFloat = scrollView.frame.width
        let currentPage:CGFloat = floor((scrollView.contentOffset.x-pageWidth/2)/pageWidth)+1
        pageControl.currentPage = Int(currentPage)
    }
}
