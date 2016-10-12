//
//  WriterNewsTableViewController.swift
//  PbSwiftPaintingLys
//  画家动态
//  Created by Maqiang on 16/2/17.
//  Copyright © 2016年 ProteanBear. All rights reserved.
//

import Foundation
import UIKit
import PbSwiftLibrary

class WriterNewsTableViewController:PbUITableViewController
{
    //blockHandleInforHeight:处理信息显示高度
    var blockHandleInforHeight:((_ toShowMax:Bool)->Void)?
    //sectionId:记录当前的栏目标识
    var sectionId:String?{
        didSet{
            if(self.sectionId != nil)
            {
                self.pbLoadData(.first)
            }
        }
    }
    
    //视图载入后载入数据
    override func viewDidLoad()
    {
        super.viewDidLoad()
        self.loadTableCell?.backgroundColor=UIColor.clear
    }
    
    //是否支持表格顶部刷新
    override func pbSupportHeaderRefresh() -> Bool
    {
        return false
    }
    
    //返回当前数据访问使用的链接标识
    override func pbKeyForDataLoad() -> String?
    {
        return "busiCmsArticle"
    }
    
    //返回当前数据访问使用的参数
    override func pbParamsForDataLoad(_ updateMode: PbDataUpdateMode) -> NSMutableDictionary?
    {
        return self.sectionId==nil ? nil:NSMutableDictionary(dictionary: ["sectionCode":self.sectionId!])
    }
    
    //解析处理返回的数据
    override func pbResolveFromResponse(_ response: NSDictionary) -> AnyObject?
    {
        var dataList:NSArray?
        
        let successObj: AnyObject?=response.object(forKey: "success") as AnyObject?
        if(successObj != nil)
        {
            let success=successObj as! Bool
            if(success)
            {
                dataList=response.object(forKey: "list") as? NSArray
            }
            else
            {
                self.pbErrorForDataLoad(PbUIViewControllerErrorType.serverError, error:(response.object(forKey: "infor") as! String))
            }
        }
        
        return dataList
    }
    
    //返回指定位置的单元格标识
    override func pbIdentifierForTableView(_ indexPath: IndexPath, data: AnyObject?) -> String
    {
        if(data == nil){return ""}
        let photo:String?=(data as! NSDictionary).object(forKey: self.pbPhotoKeyInIndexPath(indexPath)!) as? String
        return photo != nil && "" != photo ? "WriterNewsCellWithImage":"WriterNewsCellNoImage"
    }
    
    //设置表格数据显示
    override func pbSetDataForTableView(_ cell: AnyObject, data: AnyObject?, photoRecord: PbDataPhotoRecord?, indexPath: IndexPath) -> AnyObject
    {
        //带图片
        if(cell.isKind(of: WriterNewsCellWithImage.self))
        {
            let cell=cell as! WriterNewsCellWithImage

            cell.titleLabel.text=data!.object(forKey: "articleTitle") as! String?
            cell.summaryTextView.text=data!.object(forKey: "articleSummary") as! String?
            cell.dateLabel.text=data!.object(forKey: "articleReleaseTime") as! String?
            
            if(photoRecord != nil)
            {
                switch(photoRecord!.state)
                {
                case .new:
                    self.pbAddPhotoTaskToQueue(indexPath, data: data)
                    cell.titleImageView.image=nil
                case .downloaded:
                    cell.titleImageView.pbAnimation(photoRecord?.image, scale: 1, lowMode: .scaleAspectFill, overMode: .scaleAspectFill)
                case .failed:
                    cell.titleImageView.image=nil
                default:
                    cell.titleImageView.image=nil
                }
            }
            else
            {
                //设置默认图片
                cell.titleImageView.image=nil
            }
        }
        //不带图片
        else
        {
            let cell=cell as! WriterNewsCellNoImage
            
            cell.titleLabel.text=data!.object(forKey: "articleTitle") as! String?
            cell.summaryTextView.text=data!.object(forKey: "articleSummary") as! String?
        }
        
        return cell
    }
    
    //返回单元格中的网络图片标识（不设置则无网络图片下载任务）
    override func pbPhotoKeyInIndexPath(_ indexPath: IndexPath) -> String?
    {
        return "articleImageTitle"
    }
    
    //返回正常单元格的高度
    override func pbNormalHeightForRowAtIndexPath(_ tableView: UITableView, indexPath: IndexPath) -> CGFloat
    {
        return 120
    }
    
    //设置指示器的颜色
    override func pbUIRefreshActivityDefaultColor() -> UIColor
    {
        return UIColor.pbGrey(.level600)
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat
    {
        return 44
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
    {
        let data=self.tableData?.object(at: indexPath.row)
        NotificationCenter.default.post(
            name: NSNotification.Name(rawValue: "doWhenTapToView"), object: self, userInfo:
            ["identifier":"worksToContentText","data":data!])
    }
    
    override func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool)
    {
        super.scrollViewDidEndDragging(scrollView, willDecelerate: decelerate)
        
        if(self.blockHandleInforHeight != nil)
        {
            if(scrollView.contentOffset.y>44)
            {
                self.blockHandleInforHeight!(false)
            }
            if(scrollView.contentOffset.y < (-20))
            {
                self.blockHandleInforHeight!(true)
            }
        }
    }
}
