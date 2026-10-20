// Ported from upstream moodist src/data/sounds/*.tsx at the commit pinned
// in tool/fetch_sounds.sh. Keep ids in sync with assets/sounds/ file names.
import 'package:flutter/material.dart';

import '../models/sound.dart';
import '../models/sound_category.dart';

abstract final class SoundCatalog {
  static const List<SoundCategory> categories = [
    SoundCategory(
      id: 'nature',
      title: 'Nature',
      icon: Icons.forest,
      sounds: [
        Sound(
          id: 'river',
          label: 'River',
          assetPath: 'assets/sounds/nature/river.ogg',
          icon: Icons.water,
        ),
        Sound(
          id: 'waves',
          label: 'Waves',
          assetPath: 'assets/sounds/nature/waves.ogg',
          icon: Icons.waves,
        ),
        Sound(
          id: 'campfire',
          label: 'Campfire',
          assetPath: 'assets/sounds/nature/campfire.ogg',
          icon: Icons.local_fire_department,
        ),
        Sound(
          id: 'wind',
          label: 'Wind',
          assetPath: 'assets/sounds/nature/wind.ogg',
          icon: Icons.air,
        ),
        Sound(
          id: 'howling-wind',
          label: 'Howling Wind',
          assetPath: 'assets/sounds/nature/howling-wind.ogg',
          icon: Icons.cyclone,
        ),
        Sound(
          id: 'wind-in-trees',
          label: 'Wind in Trees',
          assetPath: 'assets/sounds/nature/wind-in-trees.ogg',
          icon: Icons.forest,
        ),
        Sound(
          id: 'waterfall',
          label: 'Waterfall',
          assetPath: 'assets/sounds/nature/waterfall.ogg',
          icon: Icons.waterfall_chart,
        ),
        Sound(
          id: 'walk-in-snow',
          label: 'Walk in Snow',
          assetPath: 'assets/sounds/nature/walk-in-snow.ogg',
          icon: Icons.ac_unit,
        ),
        Sound(
          id: 'walk-on-leaves',
          label: 'Walk on Leaves',
          assetPath: 'assets/sounds/nature/walk-on-leaves.ogg',
          icon: Icons.eco,
        ),
        Sound(
          id: 'walk-on-gravel',
          label: 'Walk on Gravel',
          assetPath: 'assets/sounds/nature/walk-on-gravel.ogg',
          icon: Icons.terrain,
        ),
        Sound(
          id: 'droplets',
          label: 'Droplets',
          assetPath: 'assets/sounds/nature/droplets.ogg',
          icon: Icons.water_drop,
        ),
        Sound(
          id: 'jungle',
          label: 'Jungle',
          assetPath: 'assets/sounds/nature/jungle.ogg',
          icon: Icons.park,
        ),
      ],
    ),
    SoundCategory(
      id: 'rain',
      title: 'Rain',
      icon: Icons.cloud,
      sounds: [
        Sound(
          id: 'light-rain',
          label: 'Light Rain',
          assetPath: 'assets/sounds/rain/light-rain.ogg',
          icon: Icons.grain,
        ),
        Sound(
          id: 'heavy-rain',
          label: 'Heavy Rain',
          assetPath: 'assets/sounds/rain/heavy-rain.ogg',
          icon: Icons.cloud,
        ),
        Sound(
          id: 'thunder',
          label: 'Thunder',
          assetPath: 'assets/sounds/rain/thunder.ogg',
          icon: Icons.thunderstorm,
        ),
        Sound(
          id: 'rain-on-window',
          label: 'Rain on Window',
          assetPath: 'assets/sounds/rain/rain-on-window.ogg',
          icon: Icons.window,
        ),
        Sound(
          id: 'rain-on-car-roof',
          label: 'Rain on Car Roof',
          assetPath: 'assets/sounds/rain/rain-on-car-roof.ogg',
          icon: Icons.directions_car,
        ),
        Sound(
          id: 'rain-on-umbrella',
          label: 'Rain on Umbrella',
          assetPath: 'assets/sounds/rain/rain-on-umbrella.ogg',
          icon: Icons.umbrella,
        ),
        Sound(
          id: 'rain-on-tent',
          label: 'Rain on Tent',
          assetPath: 'assets/sounds/rain/rain-on-tent.ogg',
          icon: Icons.night_shelter,
        ),
        Sound(
          id: 'rain-on-leaves',
          label: 'Rain on Leaves',
          assetPath: 'assets/sounds/rain/rain-on-leaves.ogg',
          icon: Icons.eco,
        ),
      ],
    ),
    SoundCategory(
      id: 'animals',
      title: 'Animals',
      icon: Icons.pets,
      sounds: [
        Sound(
          id: 'birds',
          label: 'Birds',
          assetPath: 'assets/sounds/animals/birds.ogg',
          icon: Icons.flutter_dash,
        ),
        Sound(
          id: 'seagulls',
          label: 'Seagulls',
          assetPath: 'assets/sounds/animals/seagulls.ogg',
          icon: Icons.waves,
        ),
        Sound(
          id: 'crickets',
          label: 'Crickets',
          assetPath: 'assets/sounds/animals/crickets.ogg',
          icon: Icons.bug_report,
        ),
        Sound(
          id: 'wolf',
          label: 'Wolf',
          assetPath: 'assets/sounds/animals/wolf.ogg',
          icon: Icons.pets,
        ),
        Sound(
          id: 'owl',
          label: 'Owl',
          assetPath: 'assets/sounds/animals/owl.ogg',
          icon: Icons.nightlight,
        ),
        Sound(
          id: 'frog',
          label: 'Frog',
          assetPath: 'assets/sounds/animals/frog.ogg',
          icon: Icons.grass,
        ),
        Sound(
          id: 'dog-barking',
          label: 'Dog Barking',
          assetPath: 'assets/sounds/animals/dog-barking.ogg',
          icon: Icons.pets,
        ),
        Sound(
          id: 'horse-gallop',
          label: 'Horse Gallop',
          assetPath: 'assets/sounds/animals/horse-gallop.ogg',
          icon: Icons.speed,
        ),
        Sound(
          id: 'cat-purring',
          label: 'Cat Purring',
          assetPath: 'assets/sounds/animals/cat-purring.ogg',
          icon: Icons.favorite,
        ),
        Sound(
          id: 'crows',
          label: 'Crows',
          assetPath: 'assets/sounds/animals/crows.ogg',
          icon: Icons.flutter_dash,
        ),
        Sound(
          id: 'whale',
          label: 'Whale',
          assetPath: 'assets/sounds/animals/whale.ogg',
          icon: Icons.water,
        ),
        Sound(
          id: 'beehive',
          label: 'Beehive',
          assetPath: 'assets/sounds/animals/beehive.ogg',
          icon: Icons.hexagon,
        ),
        Sound(
          id: 'woodpecker',
          label: 'Woodpecker',
          assetPath: 'assets/sounds/animals/woodpecker.ogg',
          icon: Icons.forest,
        ),
        Sound(
          id: 'chickens',
          label: 'Chickens',
          assetPath: 'assets/sounds/animals/chickens.ogg',
          icon: Icons.egg,
        ),
        Sound(
          id: 'cows',
          label: 'Cows',
          assetPath: 'assets/sounds/animals/cows.ogg',
          icon: Icons.agriculture,
        ),
        Sound(
          id: 'sheep',
          label: 'Sheep',
          assetPath: 'assets/sounds/animals/sheep.ogg',
          icon: Icons.cruelty_free,
        ),
      ],
    ),
    SoundCategory(
      id: 'urban',
      title: 'Urban',
      icon: Icons.location_city,
      sounds: [
        Sound(
          id: 'highway',
          label: 'Highway',
          assetPath: 'assets/sounds/urban/highway.ogg',
          icon: Icons.add_road,
        ),
        Sound(
          id: 'road',
          label: 'Road',
          assetPath: 'assets/sounds/urban/road.ogg',
          icon: Icons.edit_road,
        ),
        Sound(
          id: 'ambulance-siren',
          label: 'Ambulance Siren',
          assetPath: 'assets/sounds/urban/ambulance-siren.ogg',
          icon: Icons.medical_services,
        ),
        Sound(
          id: 'busy-street',
          label: 'Busy Street',
          assetPath: 'assets/sounds/urban/busy-street.ogg',
          icon: Icons.location_city,
        ),
        Sound(
          id: 'crowd',
          label: 'Crowd',
          assetPath: 'assets/sounds/urban/crowd.ogg',
          icon: Icons.groups,
        ),
        Sound(
          id: 'traffic',
          label: 'Traffic',
          assetPath: 'assets/sounds/urban/traffic.ogg',
          icon: Icons.traffic,
        ),
        Sound(
          id: 'fireworks',
          label: 'Fireworks',
          assetPath: 'assets/sounds/urban/fireworks.ogg',
          icon: Icons.celebration,
        ),
      ],
    ),
    SoundCategory(
      id: 'places',
      title: 'Places',
      icon: Icons.place,
      sounds: [
        Sound(
          id: 'cafe',
          label: 'Cafe',
          assetPath: 'assets/sounds/places/cafe.ogg',
          icon: Icons.local_cafe,
        ),
        Sound(
          id: 'airport',
          label: 'Airport',
          assetPath: 'assets/sounds/places/airport.ogg',
          icon: Icons.local_airport,
        ),
        Sound(
          id: 'church',
          label: 'Church',
          assetPath: 'assets/sounds/places/church.ogg',
          icon: Icons.church,
        ),
        Sound(
          id: 'temple',
          label: 'Temple',
          assetPath: 'assets/sounds/places/temple.ogg',
          icon: Icons.temple_buddhist,
        ),
        Sound(
          id: 'construction-site',
          label: 'Construction Site',
          assetPath: 'assets/sounds/places/construction-site.ogg',
          icon: Icons.construction,
        ),
        Sound(
          id: 'underwater',
          label: 'Underwater',
          assetPath: 'assets/sounds/places/underwater.ogg',
          icon: Icons.scuba_diving,
        ),
        Sound(
          id: 'crowded-bar',
          label: 'Crowded Bar',
          assetPath: 'assets/sounds/places/crowded-bar.ogg',
          icon: Icons.local_bar,
        ),
        Sound(
          id: 'night-village',
          label: 'Night Village',
          assetPath: 'assets/sounds/places/night-village.ogg',
          icon: Icons.holiday_village,
        ),
        Sound(
          id: 'subway-station',
          label: 'Subway Station',
          assetPath: 'assets/sounds/places/subway-station.ogg',
          icon: Icons.subway,
        ),
        Sound(
          id: 'office',
          label: 'Office',
          assetPath: 'assets/sounds/places/office.ogg',
          icon: Icons.business,
        ),
        Sound(
          id: 'supermarket',
          label: 'Supermarket',
          assetPath: 'assets/sounds/places/supermarket.ogg',
          icon: Icons.local_grocery_store,
        ),
        Sound(
          id: 'carousel',
          label: 'Carousel',
          assetPath: 'assets/sounds/places/carousel.ogg',
          icon: Icons.attractions,
        ),
        Sound(
          id: 'laboratory',
          label: 'Laboratory',
          assetPath: 'assets/sounds/places/laboratory.ogg',
          icon: Icons.science,
        ),
        Sound(
          id: 'laundry-room',
          label: 'Laundry Room',
          assetPath: 'assets/sounds/places/laundry-room.ogg',
          icon: Icons.local_laundry_service,
        ),
        Sound(
          id: 'restaurant',
          label: 'Restaurant',
          assetPath: 'assets/sounds/places/restaurant.ogg',
          icon: Icons.restaurant,
        ),
        Sound(
          id: 'library',
          label: 'Library',
          assetPath: 'assets/sounds/places/library.ogg',
          icon: Icons.local_library,
        ),
      ],
    ),
    SoundCategory(
      id: 'transport',
      title: 'Transport',
      icon: Icons.directions_transit,
      sounds: [
        Sound(
          id: 'train',
          label: 'Train',
          assetPath: 'assets/sounds/transport/train.ogg',
          icon: Icons.train,
        ),
        Sound(
          id: 'inside-a-train',
          label: 'Inside a Train',
          assetPath: 'assets/sounds/transport/inside-a-train.ogg',
          icon: Icons.directions_railway,
        ),
        Sound(
          id: 'airplane',
          label: 'Airplane',
          assetPath: 'assets/sounds/transport/airplane.ogg',
          icon: Icons.flight,
        ),
        Sound(
          id: 'submarine',
          label: 'Submarine',
          assetPath: 'assets/sounds/transport/submarine.ogg',
          icon: Icons.anchor,
        ),
        Sound(
          id: 'sailboat',
          label: 'Sailboat',
          assetPath: 'assets/sounds/transport/sailboat.ogg',
          icon: Icons.sailing,
        ),
        Sound(
          id: 'rowing-boat',
          label: 'Rowing Boat',
          assetPath: 'assets/sounds/transport/rowing-boat.ogg',
          icon: Icons.rowing,
        ),
      ],
    ),
    SoundCategory(
      id: 'things',
      title: 'Things',
      icon: Icons.widgets,
      sounds: [
        Sound(
          id: 'keyboard',
          label: 'Keyboard',
          assetPath: 'assets/sounds/things/keyboard.ogg',
          icon: Icons.keyboard,
        ),
        Sound(
          id: 'typewriter',
          label: 'Typewriter',
          assetPath: 'assets/sounds/things/typewriter.ogg',
          icon: Icons.edit_note,
        ),
        Sound(
          id: 'paper',
          label: 'Paper',
          assetPath: 'assets/sounds/things/paper.ogg',
          icon: Icons.description,
        ),
        Sound(
          id: 'clock',
          label: 'Clock',
          assetPath: 'assets/sounds/things/clock.ogg',
          icon: Icons.schedule,
        ),
        Sound(
          id: 'wind-chimes',
          label: 'Wind Chimes',
          assetPath: 'assets/sounds/things/wind-chimes.ogg',
          icon: Icons.music_note,
        ),
        Sound(
          id: 'singing-bowl',
          label: 'Singing Bowl',
          assetPath: 'assets/sounds/things/singing-bowl.ogg',
          icon: Icons.album,
        ),
        Sound(
          id: 'ceiling-fan',
          label: 'Ceiling Fan',
          assetPath: 'assets/sounds/things/ceiling-fan.ogg',
          icon: Icons.wind_power,
        ),
        Sound(
          id: 'dryer',
          label: 'Dryer',
          assetPath: 'assets/sounds/things/dryer.ogg',
          icon: Icons.dry,
        ),
        Sound(
          id: 'slide-projector',
          label: 'Slide Projector',
          assetPath: 'assets/sounds/things/slide-projector.ogg',
          icon: Icons.slideshow,
        ),
        Sound(
          id: 'boiling-water',
          label: 'Boiling Water',
          assetPath: 'assets/sounds/things/boiling-water.ogg',
          icon: Icons.soup_kitchen,
        ),
        Sound(
          id: 'bubbles',
          label: 'Bubbles',
          assetPath: 'assets/sounds/things/bubbles.ogg',
          icon: Icons.bubble_chart,
        ),
        Sound(
          id: 'tuning-radio',
          label: 'Tuning Radio',
          assetPath: 'assets/sounds/things/tuning-radio.ogg',
          icon: Icons.radio,
        ),
        Sound(
          id: 'morse-code',
          label: 'Morse Code',
          assetPath: 'assets/sounds/things/morse-code.ogg',
          icon: Icons.graphic_eq,
        ),
        Sound(
          id: 'washing-machine',
          label: 'Washing Machine',
          assetPath: 'assets/sounds/things/washing-machine.ogg',
          icon: Icons.local_laundry_service,
        ),
        Sound(
          id: 'vinyl-effect',
          label: 'Vinyl Effect',
          assetPath: 'assets/sounds/things/vinyl-effect.ogg',
          icon: Icons.album,
        ),
        Sound(
          id: 'windshield-wipers',
          label: 'Windshield Wipers',
          assetPath: 'assets/sounds/things/windshield-wipers.ogg',
          icon: Icons.directions_car,
        ),
      ],
    ),
    SoundCategory(
      id: 'noise',
      title: 'Noise',
      icon: Icons.graphic_eq,
      sounds: [
        Sound(
          id: 'white-noise',
          label: 'White Noise',
          assetPath: 'assets/sounds/noise/white-noise.ogg',
          icon: Icons.blur_on,
        ),
        Sound(
          id: 'pink-noise',
          label: 'Pink Noise',
          assetPath: 'assets/sounds/noise/pink-noise.ogg',
          icon: Icons.blur_linear,
        ),
        Sound(
          id: 'brown-noise',
          label: 'Brown Noise',
          assetPath: 'assets/sounds/noise/brown-noise.ogg',
          icon: Icons.blur_circular,
        ),
      ],
    ),
  ];

  static List<Sound> get allSounds => [
    for (final category in categories) ...category.sounds,
  ];

  static Sound? byId(String id) {
    for (final sound in allSounds) {
      if (sound.id == id) return sound;
    }
    return null;
  }
}
