//
//  WorksFavoriteCell.swift
//  PbSwiftPaintingLys
//
//  Created by Maqiang on 16/2/23.
//  Copyright © 2016年 ProteanBear. All rights reserved.
//

import Foundation
import UIKit

class WorksFavoriteCell: UICollectionViewCell
{
    @IBOutlet weak var titleImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var selectedImageView: UIImageView!
    
    func cellSelect(_ selected:Bool)
    {
        self.contentView.layer.borderWidth=1
        self.contentView.layer.borderColor=(selected ? UIColor.pbGrey(.level600).cgColor:UIColor.white.cgColor)
        self.selectedImageView.isHidden = !selected
    }
    
    override func layoutSubviews()
    {
        super.layoutSubviews()
        
        self.titleImageView.layer.borderWidth=0
        self.contentView.layer.shadowColor=UIColor.darkGray.cgColor
        self.contentView.layer.shadowOffset=CGSize(width: 1,height: 1)
        self.contentView.layer.shadowRadius=2
        self.contentView.layer.shadowOpacity=0.3
    }
}
