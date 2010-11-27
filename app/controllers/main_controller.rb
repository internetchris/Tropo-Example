class MainController < ApplicationController
  
    require 'tropo-webapi-ruby'
    require 'net/http' 
    require 'uri'
  
  def make_call
    
    if request.post?
         @my_tropo_token = "2ea876cdef0fd04ba3325bf2dce7f965f672ada9484ac3816be2395bf6eaba1e75b2a6fee4166168fecf1190"
         @API_URL='http://api.tropo.com/1.0/sessions?action=create&' 
         Net::HTTP.get_print URI.parse(URI.encode(@API_URL+'&token='+@my_tropo_token+'&number_to_dial='+params[:call][:number]+"&message="+params[:call][:message]+'&from_number='+params[:call][:from])) 
         redirect_to root_path
    end
  end
    
  
  def handle_calls # this is the URL placed in your TROPO account for handling voice calls. 
    tropo_session = Tropo::Generator.parse(request.env["rack.input"].read)
     puts tropo_session # Helps you see the paramaters passed back. You can pass anything to help redirect to the proper method (ie. emergency, normal call, etc)         
          tropo = Tropo::Generator.new do
            #on :event => 'hangup', :next => '/hangup.json'
            message = tropo_session['session']['parameters']['message']
            url = URI.encode("/speak/#{message}")
            on :event => 'continue', :next => url
            call(:to=>"tel:+1" + tropo_session['session']['parameters']['number_to_dial'],:from => tropo_session['session']['parameters']['from_number'])     
          end
          render :json => tropo
  end
  
  def speak
    message_to_deliver = params[:message]
     puts "Message:#{message_to_deliver}" 
     sleep 1
     tropo = Tropo::Generator.new do
       on :event => 'continue', :next => '/hangup'
       say "#{message_to_deliver}", :voice => 'allison'
     end
     render :json => tropo
    
  end
  
  def hangup
     json_string = request.env["rack.input"].read
     tropo_session = Tropo::Generator.parse json_string
     puts tropo_session 
  end
    
end
