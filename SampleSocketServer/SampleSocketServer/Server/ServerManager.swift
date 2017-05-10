//
//  ServerManager.swift
//  SampleSocketServer
//
//  Created by tianshu wei on 2017/5/10.
//  Copyright © 2017年 idlebook. All rights reserved.
//

import Cocoa

class ServerManager: NSObject {
    // MARK:- 懒加载
    // 绑定端口号
    fileprivate lazy var serverSocket: TCPServer = TCPServer(addr: "0.0.0.0", port: 7878)
    fileprivate var isServerRunning : Bool = false
    fileprivate lazy var clientMrgs : [ClientManager] = [ClientManager]()
    

}

// MARK:- 开启/关闭服务
extension ServerManager{
    func startRunning(){
        // 开启监听
        serverSocket.listen()
        isServerRunning = true
        
        // 开启接受客户端(堵塞式)
        DispatchQueue.global().async {
            // 开启循坏保证一直接受客户端的响应
            while self.isServerRunning{
                if let client = self.serverSocket.accept(){
                    // 开启一个新的线程保证处理每个客户端的响应
                    DispatchQueue.global().async {
                        self.handlerClient(client)
                    }
                }
            }
        }
    }
    
    func stopRunning() {
        isServerRunning = false
    }
}

// MARK:- 处理客户端的逻辑
extension ServerManager{
    func handlerClient(_ client: TCPClient){
        let mgr = ClientManager(tcpClient: client)
        mgr.delegate = self
        
        // 保存客户端
        clientMrgs.append(mgr)
        
        // 接受消息
        mgr.startReadMsg()
    }
}

extension ServerManager: ClientManagerDelegate{
    
    func sendMsgToClient(_ data: Data) {
        for mgr in clientMrgs {
            mgr.tcpClient.send(data: data)
        }
    }
    
    func removeClient(_ client: ClientManager) {
        // 判断是否存在客户端
        guard let index = clientMrgs.index(of: client)else {
            return
        }
        clientMrgs.remove(at: index)
        
    }
}


