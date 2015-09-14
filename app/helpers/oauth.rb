module NCU
   module OAuth
      CALENDAR_READ = 'calendar.event.read'
      CALENDAR_WRITE = 'calendar.event.write'
      module Helpers

         def token scope
            this_token_string = token_string
            return token_err 400, 'access_token is missing' if this_token_string.nil?
            RestClient.get Settings::OAUTH_TOKEN_URL + this_token_string + '?ip=' + env['REMOTE_ADDR'], {x_ncu_api_token: Settings::NCU_API_TOKEN} do |response, request, result, &block|
               if response.code == 200
                  res = JSON.parse response.body
                  if res['scope'].include? scope
                     return res.merge token_info this_token_string
                  end
                  return token_err 403, 'insufficient_scope'
               end
               token_err 401, 'invalid_token'
            end
         end

         def token_info this_token_string
            response = RestClient.get Settings::PERSONNEL_INFO_URL, {authorization: "Bearer #{this_token_string}"}
            res = JSON.parse response.body
         end

         def token_string
            token_string_from_header || token_string_from_request_params
         end

         def token_string_from_header
            Rack::Auth::AbstractRequest::AUTHORIZATION_KEYS.each do |key|
               if env.key?(key) && token_string = env[key][/^Bearer (.*)/, 1]
                  return token_string
               end
            end
            nil
         end

         def token_string_from_request_params
            params[:access_token]
         end

         def token_err code, massage
            {:error_code => code, :error_message => massage}
         end
      end
   end
end
