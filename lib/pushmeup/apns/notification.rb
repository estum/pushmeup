module APNS
  class Notification
    attr_accessor :token, :alert, :badge, :sound, :other, :id, :expiry, :priority

    def initialize(token, message)
      @token = token
      if message.is_a?(Hash)
        @alert    = message[:alert]
        @badge    = message[:badge]
        @expiry   = message[:expiry]
        @id       = message[:id]
        @other    = message[:other]
        @priority = message[:priority]
        @sound    = message[:sound]
      elsif message.is_a?(String)
        @alert = message
      else
        raise "Notification needs to have either a Hash or String"
      end
    end

    def packaged_notification
      frame_data = [device_token_item,
                    payload_item,
                    identifier_item,
                    expiration_item,
                    priority_item].compact.join
      [2, frame_data.bytes.count, frame_data].pack('cNa*')
    end

    private

    def device_token_item
      [1, 32, @token.gsub(/[<\s>]/, '')].pack('cnH*')
    end

    def payload_item
      json = payload.to_json
      [2, json.bytes.count, json].pack('cna*')
    end

    def identifier_item
      [3, 4, @id].pack('cnN') unless @id.nil?
    end

    def expiration_item
      [4, 4, @expiry].pack('cnN') unless @expiry.nil?
    end

    def priority_item
      [5, 1, @priority].pack('cnc') unless @priority.nil?
    end

    def payload
      aps = {'aps'=> {} }
      aps['aps']['alert'] = @alert if @alert
      aps['aps']['badge'] = @badge if @badge
      aps['aps']['sound'] = @sound if @sound
      aps.merge!(@other) if @other
      aps
    end

    def ==(other)
      @alert    == other.alert &&
      @badge    == other.badge &&
      @expiry   == other.expiry &&
      @id       == other.id &&
      @other    == other.other &&
      @priority == other.priority &&
      @sound    == other.sound &&
      @token    == other.token
    end

  end
end
