 require 'rubygems'  
 require 'xmpp4r-simple'  
   
 username = gmailusername  
 password = gmailpassword
 to_username = destination_gmailusername  
   
 puts "Connecting to jabber server.."  
 jabber = Jabber::Simple.new(username+'@gmail.com',password)  
 puts "Connected."  
 jabber.deliver(to_username+"@gmail.com", "Hello..!")  
 sleep(10)
