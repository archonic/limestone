json.extract! avatar, :id
json.image_xs avatar.image[:xs].url(public: true)
json.image_sm avatar.image[:sm].url(public: true)
json.image_md avatar.image[:md].url(public: true)
json.image_lg avatar.image[:lg].url(public: true)
json.image_xl avatar.image[:xl].url(public: true)
