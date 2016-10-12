//
//  AnimationCoverViewController.swift
//  PbSwiftPaintingLys
//
//  Created by Maqiang on 16/3/7.
//  Copyright © 2016年 ProteanBear. All rights reserved.
//

import Foundation
import UIKit
import PbSwiftLibrary
fileprivate func < <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l < r
  case (nil, _?):
    return true
  default:
    return false
  }
}

fileprivate func > <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l > r
  default:
    return rhs < lhs
  }
}


class AnimationCoverViewController:UIViewController
{
    //封面图片
    var imageViewCoverList:[UIImageView]=[]
    
    //数据显示
    let coverList=[["imageName":"cover-1.jpg","title":"剪羊毛"],["imageName":"cover-2.jpg","title":"波斯迎亲"],["imageName":"launch.jpg","title":"茶有道"]]
    
    //信息视图
    @IBOutlet weak var inforView: UIVisualEffectView!
    @IBOutlet weak var titleLabel: UILabel!
    
    //点击视图进入
    @IBAction func doWhenTapView(_ sender: UITapGestureRecognizer)
    {
        self.displayInfoView()
    }
    
    //视图载入后设置
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        //根据屏幕设置大小
        self.setItemsInView()
        
        //显示动画
        self.viewAnimation(0,lastImageView: nil)
    }
    
    //设置屏幕中图片元素大小
    fileprivate func setItemsInView()
    {
        let size=PbSystem.screenSize
        
        //清除原有的
        for imageView in self.imageViewCoverList
        {
            imageView.removeFromSuperview()
        }
        self.imageViewCoverList.removeAll()
        
        //封面添加
        var index=0
        for data in self.coverList
        {
            var image=UIImage(named:data["imageName"]!)
            let isLand=(image?.size.width>image!.size.height)
            let scale=isLand ? (size.height/image!.size.height):(size.width/image!.size.width)
            image=UIImage.pbScale(image!,scale:scale)
            let imageView=UIImageView(image:image)
            
            if(index%2==0)
            {
                imageView.frame=CGRect(x: 0, y: 0, width: image!.size.width, height: image!.size.height)
            }
            else
            {
                imageView.frame=CGRect(x: isLand ? -(image!.size.width-size.width):0,y: isLand ? 0:-(image!.size.height-size.height), width: image!.size.width, height: image!.size.height)
            }
            
            imageView.isHidden=(index != 0)
            self.view.addSubview(imageView)
            self.imageViewCoverList.append(imageView)
            index += 1
        }
        
        //视图前置
        self.view.bringSubview(toFront: self.titleLabel)
        self.view.bringSubview(toFront: self.inforView)
    }
    
    //显示图片动画
    fileprivate func viewAnimation(_ index:Int,lastImageView:UIImageView?)
    {
        //索引判断
        let count=self.imageViewCoverList.count
        let size=PbSystem.screenSize
        if(index >= count)
        {
            self.displayInfoView()
            return
        }
        
        //获取标题
        self.titleLabel.text=self.coverList[index]["title"]
        
        //初始设置
        let imageView=self.imageViewCoverList[index]
        imageView.layer.opacity=0
        imageView.isHidden=false
        if(lastImageView != nil)
        {
            lastImageView?.layer.opacity=1
            lastImageView?.isHidden=false
        }
        self.titleLabel.layer.opacity=0
        self.titleLabel.isHidden=false
        
        UIView.animate(withDuration: 0.8, delay: 0, options: UIViewAnimationOptions(), animations: { () -> Void in
            
            //第一步：透明度变化
            imageView.layer.opacity=1
            self.titleLabel.layer.opacity=1
            if(lastImageView != nil)
            {
                lastImageView?.layer.opacity=0
            }
            
            }) { (finished) -> Void in
                if(finished)
                {
                    //判断图片方向
                    let isLand=(imageView.frame.size.width>imageView.frame.size.height)
                    
                    //设置隐藏
                    if(lastImageView != nil)
                    {
                        lastImageView?.isHidden=true
                        if(index%2==0)
                        {
                            lastImageView!.frame=CGRect(x: 0, y: 0, width: lastImageView!.frame.size.width, height: lastImageView!.frame.size.height)
                        }
                        else
                        {
                            lastImageView!.frame=CGRect(x: isLand ? -(lastImageView!.frame.size.width-size.width):0,y: isLand ? 0:-(lastImageView!.frame.size.height-size.height), width: lastImageView!.frame.size.width, height: lastImageView!.frame.size.height)
                        }
                    }
                    
                    //第二部：图片滚动
                    let speed=1 * Double(isLand ? (imageView.frame.size.width/size.width):(imageView.frame.size.height/size.height))
                    UIView.animate(withDuration: speed, delay:0, options: .curveEaseInOut, animations: { () -> Void in
                        
                        //横向
                        if(imageView.frame.size.width>imageView.frame.size.height)
                        {
                            imageView.frame=CGRect(x: imageView.frame.origin.x==0 ? -(imageView.frame.size.width-size.width):0, y: 0, width: imageView.frame.size.width, height: imageView.frame.size.height)
                        }
                        //纵向
                        else
                        {
                            imageView.frame=CGRect(x: 0, y: imageView.frame.origin.y==0 ? -(imageView.frame.size.height-size.height):0, width: imageView.frame.size.width, height: imageView.frame.size.height)
                        }
                        
                        }, completion: { (isFinished) -> Void in
                            if(isFinished)
                            {
                                //第三步：下一个图片
                                self.viewAnimation(index+1,lastImageView: imageView)
                            }
                    })
                }
        }
    }
    
    fileprivate func displayInfoView()
    {
        //最终步：显示应用信息
        self.titleLabel.isHidden=true
        self.inforView.layer.opacity=0
        self.inforView.isHidden=false
        UIView.animate(withDuration: 0.8, delay: 0, options: UIViewAnimationOptions(), animations: { () -> Void in
            
            self.inforView.layer.opacity=1
            
            }, completion: { (finished) -> Void in
                
                if(finished)
                {
                    self.performSegue(withIdentifier: "coverToMainPage", sender: self)
                }
        })
    }
}
