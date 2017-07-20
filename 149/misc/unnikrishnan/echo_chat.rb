 require 'rubygems'  
 require 'xmpp4r-simple'  
   
 username = gmailusername  
 password = gmailpassword
 to_username = destination_gmailusername  
 
   
 puts "connecting to jabber server"  
 jabber = Jabber::Simple.new(username+'@gmail.com',password)  
 puts "Connected."  
 jabber.deliver(to_username+"@gmail.com","Hello..!")  
   
 while (true) do  
         jabber.received_messages do |msg|  
                 puts "=============================================="  
                 puts msg.body  
                 puts "----------------------------------------------"
                 jabber.deliver(msg.from.node+"@gmail.com", msg.body)  
         end
	sleep(1)  
 end  
