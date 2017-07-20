 require 'rubygems'  
 require 'xmpp4r-simple'  
   
 username = gmailusername  
 password = gmailpassword
 to_username = destination_username  
   
 puts "connecting to jabber server.."  
 jabber = Jabber::Simple.new(username+'@gmail.com',password)  
 puts "connected."  
 jabber.deliver(to_username+"@gmail.com", "Hello..!")  
   
 while (true) do  
         jabber.received_messages do |msg|  
                 puts "=================================================="
                 exit if msg.body.downcase.strip == 'exit'  
                 puts msg.body  
                 puts "--------------------------------------------------"
                 stdout =  IO.popen(msg.body).read  
                 jabber.deliver(to_username+"@gmail.com", stdout)  
                 puts stdout  
         end  
 end  
