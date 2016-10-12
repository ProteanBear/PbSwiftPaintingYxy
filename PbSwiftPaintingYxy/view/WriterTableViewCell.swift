//
//  WriterTableViewCell.swift
//  PbSwiftPaintingLys
//
//  Created by Maqiang on 16/2/17.
//  Copyright © 2016年 ProteanBear. All rights reserved.
//

import Foundation
import UIKit

//作家信息单元格
class WriterInforCell:UITableViewCell
{
    @IBOutlet weak var backImageView: UIImageView!
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        self.backImageView.layer.shadowColor=UIColor.darkGray.cgColor
        self.backImageView.layer.shadowOffset=CGSize(width: 1, height: 1)
        self.backImageView.layer.shadowOpacity=0.4
        self.backImageView.layer.shadowRadius=1.8
    }
}

//动态单元格，带图片
class WriterNewsCellWithImage: UITableViewCell
{
    @IBOutlet weak var titleImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var summaryTextView: UITextView!
    @IBOutlet weak var dateLabel: UILabel!
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        self.summaryTextView.textColor=UIColor.darkGray
    }
    
    override func draw(_ rect: CGRect)
    {
        let context = UIGraphicsGetCurrentContext()
        
        let width:CGFloat=0.1
        context?.setLineWidth(width)
        context?.setStrokeColor(UIColor.black.cgColor)
        
        context?.move(to: CGPoint(x: 20, y: self.frame.size.height-width))
        context?.addLine(to: CGPoint(x: self.frame.size.width-20, y: self.frame.size.height-width))
        
        context?.strokePath()
    }
}

//动态单元格，不带图片
class WriterNewsCellNoImage:UITableViewCell
{
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var summaryTextView: UITextView!
    @IBOutlet weak var dateLabel: UILabel!
    
    override func layoutSubviews()
    {
        super.layoutSubviews()
        
        self.summaryTextView.textColor=UIColor.darkGray
    }
    
    override func draw(_ rect: CGRect)
    {
        let context = UIGraphicsGetCurrentContext()
        
        let width:CGFloat=0.1
        context?.setLineWidth(width)
        context?.setStrokeColor(UIColor.black.cgColor)
        
        context?.move(to: CGPoint(x: 20, y: self.frame.size.height-width))
        context?.addLine(to: CGPoint(x: self.frame.size.width-20, y: self.frame.size.height-width))
        
        context?.strokePath()
    }
}

//视频单元格
class WriterVideoCell: UICollectionViewCell
{
    @IBOutlet weak var titleImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var playImageView: UIImageView!
    
    override func layoutSubviews()
    {
        super.layoutSubviews()
        self.contentView.layer.borderColor=UIColor.pbGrey(.level500).cgColor
        self.contentView.layer.borderWidth=1
    }
}
