//
//  ContentTextViewController.swift
//  PbSwiftPaintingLys
//  内容视图：文本内容
//  Created by Maqiang on 16/2/19.
//  Copyright © 2016年 ProteanBear. All rights reserved.
//

import Foundation
import UIKit
import PbSwiftLibrary

class ContentTextViewController: CustomViewController,PbUIViewControllerProtocol,UIWebViewDelegate,UMSocialUIDelegate
{
    //indicator:指示器
    var indicator:PbUIActivityIndicator?
    //summary:记录当前文章简介
    var summary=""
    //articleId:文章标识
    var articleId:String?{
        didSet{
            
            if(self.articleId==nil || ""==self.articleId){return}
            
            //设置后载入数据
            self.pbLoadData(.first, controller: self)
        }
    }
    //articleTitle:文章标题
    var articleTitle=""
    
    //contentWebView:Web内容
    @IBOutlet weak var contentWebView: UIWebView!
    
    //viewDidLoad:增加顶部分享按钮
    override func viewDidLoad()
    {
        super.viewDidLoad()
        self.setBarRightItem()
    }
    
    //doWhenTapShareButton:点击分享按钮
    func doWhenTapShareButton(_ button:AnyObject)
    {
        var shareText="【("+self.articleTitle+")来自"
        shareText+=(Bundle.main.object(forInfoDictionaryKey: "CFBundleDisplayName") as! String)+"iPhone客户端】"+self.summary
        
        UMSocialData.default().extConfig.wechatSessionData.urlResource.setResourceType(UMSocialUrlResourceTypeImage, url:UMKeyData.url)
        UMSocialData.default().extConfig.wechatTimelineData.urlResource.setResourceType(UMSocialUrlResourceTypeImage, url:UMKeyData.url)
        UMSocialData.default().extConfig.wechatFavoriteData.urlResource.setResourceType(UMSocialUrlResourceTypeImage, url:UMKeyData.url)
        UMSocialData.default().extConfig.qqData.urlResource.setResourceType(UMSocialUrlResourceTypeImage, url:UMKeyData.url)
        
        UMSocialSnsService.presentSnsIconSheetView(self, appKey:UMKeyData.appKey, shareText: shareText, shareImage: UIImage(named:"icon120.png"), shareToSnsNames:UMKeyData.shareToSnsNames, delegate:self)
    }
    
    /*----------开始：实现PbUIViewControllerProtocol委托*/
    //pbKeyForDataLoad:返回当前数据访问使用的链接标识
    func pbKeyForDataLoad() -> String?
    {
        return "busiCmsArticle"
    }
    
    //pbParamsForDataLoad:返回当前数据访问使用的参数
    func pbParamsForDataLoad(_ updateMode:PbDataUpdateMode) -> NSMutableDictionary?
    {
        return NSMutableDictionary(dictionary: ["primaryKey":self.articleId!])
    }
    
    //pbResolveFromResponse:解析处理返回的数据
    func pbResolveFromResponse(_ response:NSDictionary) -> AnyObject?
    {
        var dataList:NSArray?
        
        let successObj: AnyObject?=response.object(forKey: "success") as AnyObject?
        if(successObj != nil)
        {
            let success=successObj as! Bool
            if(success)
            {
                dataList=response.object(forKey: "list") as? NSArray
                if(dataList != nil && dataList!.count>0)
                {
                    let data:NSDictionary=dataList!.object(at: 0) as! NSDictionary
                    self.summary=(data.object(forKey: "articleSummary") as! String)
                    let html=NSString(
                        format:"<!DOCTYPE html><html><head><meta http-equiv=\"Content-Type\" content=\"text/html; charset=UTF-8\"><style><!--%@--></style><script>%@\n%@\n%@</script></head><body><header><h1>%@</h1><h2>%@</h2><h2>%@</h2></header><section id='content'>%@</section><footer></footer></body></html>",
                        self.cssStyleForHtml(),
                        self.javascriptForClearFontStyle(),
                        self.javascriptForSetFontSize(),
                        self.javascriptForSetLineHeight(),
                        data.object(forKey:"articleTitle") as! String,
                        "<img src=\""+PbDataAppController.instance.fullUrl("upload/1000/top_line.png")+"\" style=\"width:220px;\" />",
                        data.object(forKey:"articleReleaseTime") as! String,
                        data.object(forKey: "articleContent") as! String
                    )
                    
                    self.articleTitle=(data.object(forKey: "articleTitle") as! String)
                    self.contentWebView.loadHTMLString(html as String, baseURL: nil)
                }
            }
            else
            {
                self.pbErrorForDataLoad(.serverError, error:(response.object(forKey: "infor") as! String))
            }
        }
        
        return dataList
    }
    
    func pbResolveFromResponse(_ response:NSDictionary,updateMode:PbDataUpdateMode) -> AnyObject?
    {
        return nil
    }
    
    //pbDoUIDisplayForDataLoad:执行相关返回后的视图更新处理
    func pbDoUIDisplayForDataLoad(_ response:AnyObject?,updateMode:PbDataUpdateMode,property:NSDictionary?)
    {}
    
    //pbErrorForDataLoad:出现访问错误时调用
    func pbErrorForDataLoad(_ type:PbUIViewControllerErrorType,error:String)
    {}
    
    //pbAutoUpdateAfterFirstLoad:初次载入后是否立即更新
    func pbAutoUpdateAfterFirstLoad() -> Bool
    {
        return false
    }
    
    //pbSupportActivityIndicator:是否支持载入显示器
    func pbSupportActivityIndicator() -> PbUIActivityIndicator?
    {
        if(self.indicator == nil)
        {
            let indicator=PbUIRingSpinnerCoverView(frame:CGRect(x: 0, y: 0, width: 2000, height: 2000))
            indicator.center=self.view.center
            indicator.tintColor=UIColor.pbGrey(.level600)
            indicator.backgroundColor=UIColor.white
            indicator.stopAnimating()
            self.view.addSubview(indicator)
            self.view.bringSubview(toFront: indicator)
            self.view.layoutIfNeeded()
            
            self.indicator=indicator
        }
        return self.indicator
    }
    
    //pbDoInitForDataLoad:数据适配器初始化时调用
    func pbDoInitForDataLoad(_ delegate:PbUIViewControllerProtocol?){}
    
    //pbPageKeyForDataLoad:返回当前数据访问使用的页码参数名称
    func pbPageKeyForDataLoad() -> String{return ""}
    
    //pbPropertyForDataLoad:设置数据请求回执附带属性
    func pbPropertyForDataLoad(_ updateMode:PbDataUpdateMode) -> NSDictionary?{return nil}
    
    //pbWillRequestForDataLoad:开始请求前处理
    func pbWillRequestForDataLoad(_ updateMode:PbDataUpdateMode){}
    
    //pbDoUpdateForDataLoad:执行更新类相关返回后的处理
    func pbDoUpdateForDataLoad(_ response:AnyObject?,updateMode:PbDataUpdateMode,property:NSDictionary?){}
    
    //pbDoInsertForDataLoad:执行增量类相关返回后的处理
    func pbDoInsertForDataLoad(_ response:AnyObject?,updateMode:PbDataUpdateMode,property:NSDictionary?){}
    
    //pbDoEndForDataLoad:执行数据载入结束后的处理
    func pbDoEndForDataLoad(_ response:AnyObject?,updateMode:PbDataUpdateMode,property:NSDictionary?){}
    /*----------结束：实现PbUIViewControllerProtocol委托*/
    
    /*----------开始：实现UIWebViewDelegate*/
    //HTML页面载入完成时执行
    func webViewDidFinishLoad(_ webView: UIWebView)
    {
        //清除页面中的字体相关Style
        self.toRunJavascriptByName(clearFontStyle, params:"null")
        //设置系统设置的字体大小
        self.toRunJavascriptByName(setFontStyle, params:"16")
        //设置系统设置的行距大小
        self.toRunJavascriptByName(setLineHeight, params:"16,1.4")
        
        self.indicator?.stopAnimating()
    }
    
    //捕捉UIWebView重定向请求
    func webView(_ webView: UIWebView, shouldStartLoadWith request: URLRequest, navigationType: UIWebViewNavigationType) -> Bool
    {
        return (navigationType == .other)
    }
    /*----------结束：实现UIWebViewDelegate*/
    
    /*----------开始：JS调用相关的方法*/
    //JS方法名称
    let clearFontStyle="clearFontStyle"
    let setFontStyle="setFontStyle"
    let setLineHeight="setLineHeight"
    
    //javascriptForClearFontStyle：清除所有的字体样式
    fileprivate func javascriptForClearFontStyle() -> NSString
    {
        return NSString(
            format:"function %@(parent){%@}",
            clearFontStyle,
            NSString(
                format:"parent=parent||document.getElementsByTagName('body')[0];if(parent){var child=parent.firstChild;while(child){if(child.nodeType==1){child.style.fontSize='';child.style.lineHeight='';child.style.fontFamily='';child.style.textIndent=(child.nodeName==''?'2em':'');child.style.backgroundColor='';if(child.firstChild){%@(child);}}child=child.nextSibling;}}",
                clearFontStyle
            )
        )
    }
    
    //javascriptForSetFontSize:设置字体大小
    fileprivate func javascriptForSetFontSize() -> NSString
    {
        return NSString(
            format:"function %@(fontsize){%@}",
            setFontStyle,
            "var content=document.getElementById('content');if(content){content.style.fontSize=fontsize+'px'}"
        )
    }
    
    //javascriptForSetLineHeight:设置字体行距
    fileprivate func javascriptForSetLineHeight() -> NSString
    {
        return NSString(
            format:"function %@(fontsize,lineHeight){%@}",
            setLineHeight,
            "var content=document.getElementById('content');if(content){content.style.lineHeight=(fontsize*lineHeight)+'px'}"
        )
    }
    
    //cssStyleForHtml:设置CSS样式
    fileprivate func cssStyleForHtml() -> String
    {
        return "body{background-color:transparent;margin:64px 15px 49px 15px;color:#000;}"+"ul,li,ol{list-style-type:none;margin:0;padding:0 7px;}"+".title{font-size: 18px;margin:15px 0 0 0;}"+".datetime{font-size: 14px;margin-bottom:5px;color:#888686;}"+"img{width:98%;height:auto;}"+"h1{font-size:22px;text-align:center;}"+"h2{font-size:14px;color:#999;text-align:center;}"+"a{text-decoration:none;color:#000;}"
    }
    
    //toRunJavascriptByName:执行JavaScript方法
    fileprivate func toRunJavascriptByName(_ functionName:String,params:String)
    {
        self.contentWebView.stringByEvaluatingJavaScript(from: functionName+"("+params+");")
    }
    
    //reductFontSize:缩小字体
    fileprivate func reduceFontSize()
    {}
    
    //addFontSize:增加字体
    fileprivate func addFontSize()
    {}
    
    //setFontSize:设置字体
    fileprivate func setFontSize(){}
    
    //reduceLineHeight:减少行距
    fileprivate func reduceLineHeight(){}
    
    //addLineHeight:增加行距
    fileprivate func addLineHeight(){}
    
    //编码图片
    fileprivate func htmlForJPGImage(_ image:UIImage) -> String
    {
        let imageData=UIImageJPEGRepresentation(image,1.0)
        let imageSource="data:image/png;base64,"+imageData!.base64EncodedString(options: .lineLength64Characters)
        return "<img src = \""+imageSource+"\" />"
    }
    /*----------结束：JS调用相关的方法*/
    
    /*----------开始：实现UMSocialUIDelegate委托*/
    func didFinishGetUMSocialData(inViewController response: UMSocialResponseEntity!)
    {
        if((response) != nil)
        {
            if(response.responseCode==UMSResponseCodeSuccess)
            {
                self.pbMsgTip("分享成功！", dismissAfterSecond: 0.5, position: .bottom)
            }
            else
            {
                self.pbMsgTip("出现错误："+UMKeyData.errorDictionary[response.responseCode.rawValue.description]!, dismissAfterSecond: 0.5, position: .bottom)
            }
        }
        else
        {
            self.pbMsgTip("分享失败！", dismissAfterSecond: 0.5, position: .bottom)
        }
    }
    /*----------结束：实现UMSocialUIDelegate委托*/
    
    func setBarRightItem()
    {
        //设置返回按钮
        let backView=UIButton(type:.custom)
        backView.setImage(UIImage(named:"icon_share"), for: UIControlState())
        backView.frame=CGRect(x: 0, y: 0, width: 28, height: 28)
        backView.contentMode = .center
        backView.backgroundColor=UIColor(white:0, alpha:0.8)
        backView.layer.cornerRadius=14
        backView.layer.borderColor=UIColor.white.cgColor
        backView.layer.borderWidth=0.5
        backView.addTarget(self, action:#selector(ContentTextViewController.doWhenTapShareButton(_:)), for:.touchUpInside)
        self.navigationItem.rightBarButtonItem=UIBarButtonItem(customView:backView)
    }
}
