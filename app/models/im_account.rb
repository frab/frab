class ImAccount < ApplicationRecord
  TYPES = %w(discord irc jabber mastodon matrix signal skype slack telegram whatsapp other).freeze

  # Product names are not translated.
  LABELS = {
    'discord' => 'Discord',
    'irc' => 'IRC',
    'jabber' => 'Jabber/XMPP',
    'mastodon' => 'Mastodon',
    'matrix' => 'Matrix',
    'signal' => 'Signal',
    'skype' => 'Skype',
    'slack' => 'Slack',
    'telegram' => 'Telegram',
    'whatsapp' => 'WhatsApp'
  }.freeze

  belongs_to :person

  has_paper_trail meta: { associated_id: :person_id, associated_type: 'Person' }

  def to_s
    model_name.human
  end
end
