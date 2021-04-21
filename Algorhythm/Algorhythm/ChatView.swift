//
//  ChatView.swift
//  Algorhythm
//
//  Created by Dan Bellini on 3/23/21.
//
import Foundation
import SwiftUI
import AssistantV1


struct ChatView: View {
    @State var messages : [Message] = []
    
    @State var text: String = ""
    @State var response : String = ""{
        didSet{
            messages.insert(Message(author: "Watson", contents: response), at: 0)
        }
    }
    @State var assistant : Assistant? = nil
    @State var sessionID : String = ""

    // save context to state to continue the conversation later
    @State var context: Context?
    
    let watsonEnd = URL(string: "https://api.us-south.assistant.watson.cloud.ibm.com/instances/15388fdc-8436-4a4b-9963-a63f73d6c7f0/v2/assistants/fcc9506f-de72-4d1a-a610-8f71313de6da/message?version=2020-09-24")!
    
    
    func askWatson(message:Dictionary<String, Dictionary<String, String>>){
        var request = URLRequest(url:watsonEnd)
        let b64login = String("apikey:AMDrjRAZOjSNg5qAuMYN5u-nebrkxubVvl9prClA649F")
        let b64data =  b64login.data(using: String.Encoding.utf8)
        let b64loginString = b64data!.base64EncodedString()
        request.setValue("Basic \(b64loginString)",
                         forHTTPHeaderField:"Authorization")
        request.setValue("application/json",
                         forHTTPHeaderField: "Content-Type"
        )
    
        let rbodyJson = try? JSONSerialization.data(
            withJSONObject: message,
            options: []
        )
        
        request.httpMethod = "POST"
        request.httpBody = rbodyJson
        
        let session = URLSession.shared
        let task = session.dataTask(with: request) {
            (data, response, error) in
            print("DONE RUNNING ASK QUERY")
            if let error = error {
                print("HTTP Request error!:", error)
            } else if let mdata = data {
                print("Returned data: ", String(data: mdata, encoding: String.Encoding.utf8))
                
                let json:Optional = try? JSONSerialization.jsonObject(with: mdata, options: [])
                
                if let dictionary = json as? [String:Any] {
                    if let root = dictionary["output"] as? [String: Any] {
                        print("ROOT", root)
                        if let generic = root["generic"] as? [Any] {
                            if let gd = generic[0] as? [String: String] {
                                guard let respText = gd["text"] as? String else {
                                    return
                                }
                                
                                print(respText)
                                self.response = respText
                                
                            }
                        }
                    }
                }
                
                
            } else {
                print("Unhandled error!")
            }
        }
        
        task.resume()
    }
    
    let workspace = "https://api.us-south.assistant.watson.cloud.ibm.com/instances/15388fdc-8436-4a4b-9963-a63f73d6c7f0/v1/workspaces/875f04c0-4740-4ac3-a426-f7ff0bca2f38/message"

    
    var body: some View {
        VStack {
            List(messages, id: \.contents) {
                Text("\($0.author): \($0.contents)")
                    .scaleEffect(x: 1, y: -1, anchor: .center)
            }
            .scaleEffect(x: 1, y: -1, anchor: .center)
            .offset(x: 0, y: 2)
            
            
            HStack {
                TextField("Type a message", text: $text)
                Button(action: self.send) {
                    Text("Send")
                }
            }.padding()
        }
        .navigationBarTitle("General")
        .onAppear(perform: {
            
            let authenticator = WatsonIAMAuthenticator(apiKey: "AMDrjRAZOjSNg5qAuMYN5u-nebrkxubVvl9prClA649F")
           
            assistant = Assistant(version: "2020-04-01", authenticator: authenticator)
//            assistant = Assistant(version: "2020-04-01", authenticator: authenticator)
//            assistant!.serviceURL = "https://api.us-south.assistant.watson.cloud.ibm.com"
//            assistant!.createSession(assistantID: "3cb54746-2108-4e98-a917-d0137cd92e56") {
//              response, error in
//
//              guard let session = response?.result else {
//                print(error?.localizedDescription ?? "unknown error")
//                return
//              }
//
//                sessionID = session.sessionID
//                print(session)
//            }
            assistant!.message(workspaceID: workspace) { response, error in
               if let error = error {
             //     print(error)
               }

               guard let message = response?.result else {
               //    print("Failed to get the message.")
                   return
               }

              // print("Conversation ID: \(message.context.conversationID!)")
               //print("Response: \(message.output.text.joined())")
                
                self.context = message.context
            }
        })
    }
    
    func send() {
        messages.insert(Message(author: "Me", contents: text), at: 0)
        var message = ["input": [ "text" : text]]
        askWatson(message: message)
        
        //let input = MessageInput(text: text)
        //let input = MessageInput(messageType: "text", text: "Hello")
        
      //  print(sessionID)
        
//        assistant!.message(assistantID: "0dddf61e-0eaa-400c-ae3b-b1d980adf947", sessionID: sessionID, input: input) {
//          response, error in
//
//          guard let message = response?.result else {
//            print(error?.localizedDescription ?? "unknown error")
//            return
//          }
//
//          print(message)
//        }
        
  //      print("Request: When are you open?")
        let input = MessageInput(text: "When are you open?")

        assistant!.message(workspaceID: workspace, input: input, context: self.context) { response, error in
           if let error = error {
   //           print(error)
           }

           guard let message = response?.result else {
   //            print("Failed to get the message.")
               return
           }

  //         print("Conversation ID: \(message.context.conversationID!)")
    //       print("Response: \(message.output.text.joined())")

           // Update the context
           self.context = message.context
        }



//        assistant!.message(workspaceID: "https://api.us-south.assistant.watson.cloud.ibm.com/instances/cf1d0cdc-c80a-4bd9-a0ba-a5ee7f2d2110/v1/workspaces/3cb54746-2108-4e98-a917-d0137cd92e56/message", input: input, context: self.context, completionHandler: {
//            response, error in
//
//            if let error = error {
//                  print(error)
//               }
//
//            guard let message = response?.result else {
//                   print("Failed to get the message.")
//                   return
//               }
//
//               print("Conversation ID: \(message.context.conversationID!)")
//               print("Response: \(message.output.text.joined())")
//
//               // Set the context to state
//               self.context = message.context
//        })
        text = ""
    }
}

struct Message{
    var author : String
    var contents : String
}

struct ChatView_Previews: PreviewProvider {
    static var previews: some View {
        ChatView()
    }
}


