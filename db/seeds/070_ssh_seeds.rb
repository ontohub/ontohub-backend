# frozen_string_literal: true

public_key = <<~KEY
  ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIIvfRuF3YhtXWp22cwb6Ain6cpCS8UzfEgw72LDR8jPP
KEY
name = 'ssh fixture public key'
user = User.find(slug: 'ada')
PublicKey.new(name: name, key: public_key.strip, user_id: user.id).save
