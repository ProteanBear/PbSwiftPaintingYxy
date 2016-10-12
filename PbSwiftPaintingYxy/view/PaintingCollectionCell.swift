//
//  PaintingCollectionCell.swift
//  PbSwiftPaintingLys
//  单元格：作品
//  Created by Maqiang on 16/2/15.
//  Copyright © 2016年 ProteanBear. All rights reserved.
//

import Foundation
import UIKit

class PaintingCollectionHeader: UICollectionReusableView
{
    @IBOutlet weak var dateLabel: UILabel!
}

class PaintingCollectionCell: UICollectionViewCell
{
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        self.imageView.layer.borderColor=UIColor.pbGrey(.level500).cgColor
        self.imageView.layer.borderWidth=1
    }
    
    func displayAnimation(_ image:UIImage,size:CGSize)
    {
        let preImageView=UIImageView(image:image)
        preImageView.contentMode = .scaleAspectFill
        let margin:CGFloat=20.0
        preImageView.frame=CGRect(x: -margin,y: -margin,width: size.width+margin*2, height: size.height+margin*2)
        preImageView.layer.opacity=0
        self.contentView.addSubview(preImageView)
        self.contentView.bringSubview(toFront: self.titleLabel)
        self.imageView.isHidden=true
        self.imageView.image=image
        self.contentView.clipsToBounds=false
        
        UIView.animate(withDuration: 0.5, delay: 0, options: UIViewAnimationOptions(), animations: { () -> Void in
            
            preImageView.frame=CGRect(x: 0,y: 2,width: size.width,height: size.height-4)
            preImageView.layer.opacity=1
            
            }) { (finished) -> Void in
                if(finished)
                {
                    self.contentView.clipsToBounds=true
                    preImageView.isHidden=true
                    self.imageView.isHidden=false
                }
        }
    }
}
