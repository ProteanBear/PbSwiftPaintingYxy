//
//  ContentWorksCell.swift
//  PbSwiftPaintingLys
//
//  Created by Maqiang on 16/2/20.
//  Copyright © 2016年 ProteanBear. All rights reserved.
//

import Foundation
import UIKit
import PbSwiftLibrary

class ContentWorksCell:UICollectionViewCell,UIScrollViewDelegate
{
    @IBOutlet weak var contentContainer: UIScrollView!
    var contentImageView: UIImageView?
    
    //指定缩放的视图
    func viewForZooming(in scrollView: UIScrollView) -> UIView?
    {
        return self.contentImageView
    }
    
    //重新设置缩放比例为1
    func setContentImageScale()
    {
        self.contentContainer.zoomScale=1
    }

    //设置图片大小
    func setContentImageSize(_ size:CGSize)
    {
        if(self.contentImageView == nil)
        {
            self.contentImageView=UIImageView(frame:CGRect.zero)
            self.contentImageView!.contentMode = .scaleAspectFill
            self.contentContainer.addSubview(self.contentImageView!)
        }
        self.contentImageView!.frame=CGRect(x: 0, y: 0, width: size.width,height: size.height)
    }
}
