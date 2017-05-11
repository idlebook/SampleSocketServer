//
//  ClientManager.swift
//  SampleSocketServer
//
//  Created by tianshu wei on 2017/5/10.
//  Copyright © 2017年 idlebook. All rights reserved.
//

import Cocoa


protocol ClientManagerDelegate: class {
    func sendMsgToClient(_ data: Data)
    func removeClient(_ client: ClientManager)
}


class ClientManager: NSObject {
    // MARK:- 属性
    var tcpClient: TCPClient
    
    weak var delegate: ClientManagerDelegate?
    
    fileprivate var isClientConnected: Bool = false
    fileprivate var heartTimeCount : Int = 0
    
    init(tcpClient: TCPClient) {
        self.tcpClient = tcpClient
    }

}

extension ClientManager{
    // 读取消息
    func startReadMsg(){
        isClientConnected = true
        
        let timer = Timer(fireAt: Date(), interval: 1, target: self, selector: #selector(checkHeartBeat), userInfo: nil, repeats: true)
        RunLoop.current.add(timer, forMode: .commonModes)
        timer.fire()
        
        // 头部消息长度为4, 类型长度为2
        while isClientConnected{
            // 先确定读出header的信息
            if let lMsg = tcpClient.read(4){
                // 读取长度的Data
                let headData = Data(bytes: lMsg)
                
                var length: Int = 0
                
                (headData as NSData).getBytes(&length, length: 4)
                
                // 读取类型
                guard let typeMsg = tcpClient.read(2) else {return}
                let typeData = Data(bytes: typeMsg)
                var type: Int = 0
                (typeData as NSData).getBytes(&type, length: 2)
                
                // 根据长度读取真实消息
                guard let msg = tcpClient.read(length) else {
                    return
                }
                
                let data = Data(bytes: msg, count: length)
                
                //离开房间
                if type == 1{
                    tcpClient.close()
                    delegate?.removeClient(self)
                }else if type == 100{
                    heartTimeCount = 0
                    continue
                }
                
                print(type)
                let totalData = headData + typeData + data
                delegate?.sendMsgToClient(totalData)
                
            }else {
                self.removeClient()
            }
        }
    }
    
    @objc fileprivate func checkHeartBeat(){
        heartTimeCount += 1
        if heartTimeCount >= 10 {
            self.removeClient()
        }
    }
    
    private func removeClient() {
        delegate?.removeClient(self)
        isClientConnected = false
        print("客户端断开了连接")
        tcpClient.close()
    }
}
