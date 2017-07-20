 require 'rubygems'  
 require 'xmpp4r-simple'  
  
 username = gmailusername
 password = gmailpassword
 $to_username = destination_username
   
 puts "connecting to jabber server..."  
 jabber = Jabber::Simple.new(username+'@gmail.com', password)  
 puts "Connected."  
 jabber.deliver($to_username+"@gmail.com", "Hello..!")  

 
 Thread.new{
  while true
    jabber.deliver($to_username+"@gmail.com", $stdin.gets)  
    puts "-"*80  
  end
 }

 while (true) do  
         jabber.received_messages do |msg|  
                 puts "="*80  
		 $to_username = msg.from.node
		 puts  msg.from.node + ":" + msg.body
         end 
	sleep(1) 
 end  
