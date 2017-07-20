 require 'rubygems'  
 require 'xmpp4r-simple'  
 require 'yaml'

 username = gmailusername  
 password = gmailpassword
 to_username = destination_gmailusername  
 

 puts "connecting to jabber server"  
 im = Jabber::Simple.new(username+'@gmail.com',password)  
 puts "connected."  
   
 while (true) do  
         im.received_messages do |msg|  
                 puts "==================================================================="  
                 puts msg.body  
                 puts "-------------------------------------------------------------------"  
                 im.deliver(msg.from.node+"@gmail.com","I am busy now. Catch you later buddy.")
         end  
	sleep(1)
 end  
