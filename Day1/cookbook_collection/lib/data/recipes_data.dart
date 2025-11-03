import '../models/recipe.dart';

final List<Recipe> demoRecipes = [
  Recipe(
    id: 'r1',
    title: 'Phở Bò Truyền Thống',
    thumbnail: 'assets/images/phobo.jpg',
    image: 'assets/images/phobo.jpg',
    description:
    'Phở bò với nước dùng đậm đà, bánh phở mềm và thịt bò thơm ngon.',
    ingredients: [
      '500g xương bò',
      '300g thịt bò tái',
      'Bánh phở',
      'Hành lá, ngò gai',
      'Gia vị phở, muối, đường'
    ],
    steps: [
      'Hầm xương bò 3–4 tiếng để lấy nước dùng.',
      'Nêm gia vị phở cho vừa miệng.',
      'Trụng bánh phở, xếp thịt bò lên trên.',
      'Chan nước dùng nóng, thêm hành và ngò.'
    ],
    duration: 120,
    difficulty: 'Trung bình',
  ),
  Recipe(
    id: 'r2',
    title: 'Bún Chả Hà Nội',
    thumbnail: 'assets/images/buncha.jpg',
    image: 'assets/images/buncha.jpg',
    description:
    'Bún chả với thịt nướng than hoa, nước chấm chua ngọt và rau sống.',
    ingredients: [
      '300g thịt ba chỉ',
      '200g thịt nạc xay',
      'Bún tươi',
      'Rau sống, đồ chua',
      'Nước mắm, đường, chanh, tỏi, ớt'
    ],
    steps: [
      'Ướp thịt với gia vị rồi nướng vàng.',
      'Pha nước chấm chua ngọt.',
      'Dọn bún, thịt nướng, rau và đồ chua ra tô.',
      'Rưới nước chấm và thưởng thức.'
    ],
    duration: 60,
    difficulty: 'Trung bình',
  ),
  Recipe(
    id: 'r3',
    title: 'Gỏi Cuốn Tôm Thịt',
    thumbnail: 'assets/images/goicuon.jpg',
    image: 'assets/images/goicuon.jpg',
    description:
    'Món ăn thanh mát với tôm, thịt luộc, rau sống và bún cuốn trong bánh tráng.',
    ingredients: [
      '200g tôm',
      '150g thịt ba chỉ',
      'Bún tươi',
      'Rau thơm, xà lách',
      'Bánh tráng, nước chấm'
    ],
    steps: [
      'Luộc tôm và thịt, thái lát.',
      'Trải bánh tráng, xếp rau, bún, tôm thịt.',
      'Cuốn chặt tay và chấm với nước chấm.',
    ],
    duration: 30,
    difficulty: 'Dễ',
  ),
  Recipe(
    id: 'r4',
    title: 'Cơm Tấm Sườn Bì Chả',
    thumbnail: 'assets/images/comtam.jpg',
    image: 'assets/images/comtam.jpg',
    description:
    'Cơm tấm Sài Gòn với sườn nướng, bì, chả trứng và mỡ hành thơm lừng.',
    ingredients: [
      '300g sườn cốt lết',
      'Bì heo, thính',
      'Chả trứng',
      'Cơm tấm, mỡ hành',
      'Nước mắm chua ngọt'
    ],
    steps: [
      'Ướp sườn và nướng vàng thơm.',
      'Trộn bì với thính và gia vị.',
      'Hấp chả trứng.',
      'Dọn cơm với sườn, bì, chả và nước mắm.'
    ],
    duration: 75,
    difficulty: 'Trung bình',
  ),
  Recipe(
    id: 'r5',
    title: 'Bánh Mì Thịt',
    thumbnail: 'assets/images/banhmi.jpg',
    image: 'assets/images/banhmi.jpg',
    description:
    'Bánh mì Việt Nam giòn rụm với pate, thịt nguội, đồ chua và rau thơm.',
    ingredients: [
      'Bánh mì',
      'Pate, chả lụa, jambon',
      'Dưa leo, đồ chua',
      'Rau thơm, tương ớt, mayonnaise'
    ],
    steps: [
      'Rạch bánh mì, phết pate.',
      'Thêm thịt nguội, rau, đồ chua.',
      'Chan tương ớt hoặc mayonnaise và thưởng thức.'
    ],
    duration: 10,
    difficulty: 'Dễ',
  ),
  Recipe(
    id: 'r6',
    title: 'Bánh Xèo Tôm Thịt',
    thumbnail: 'assets/images/banhxeo.jpg',
    image: 'assets/images/banhxeo.jpg',
    description:
    'Bánh xèo vàng giòn với nhân tôm thịt, giá đỗ, ăn kèm rau sống.',
    ingredients: [
      'Bột bánh xèo',
      'Nước cốt dừa, bột nghệ',
      'Tôm, thịt heo, giá đỗ',
      'Rau sống, nước chấm'
    ],
    steps: [
      'Pha bột bánh xèo với nước và nước cốt dừa.',
      'Xào sơ tôm thịt.',
      'Đổ bột lên chảo, thêm nhân, chiên giòn rồi gập đôi.'
    ],
    duration: 45,
    difficulty: 'Trung bình',
  ),
  Recipe(
    id: 'r7',
    title: 'Gà Rán Mật Ong',
    thumbnail: 'assets/images/garan.jpg',
    image: 'assets/images/garan.jpg',
    description:
    'Gà rán giòn rụm áo sốt mật ong chua ngọt hấp dẫn, kiểu Tasty.',
    ingredients: [
      '500g cánh gà',
      'Bột chiên giòn',
      'Mật ong, nước tương',
      'Tỏi băm, dầu ăn'
    ],
    steps: [
      'Ướp gà và áo bột, chiên vàng.',
      'Nấu sốt mật ong trên chảo.',
      'Cho gà vào đảo đều với sốt.'
    ],
    duration: 40,
    difficulty: 'Dễ',
  ),
  Recipe(
    id: 'r8',
    title: 'Canh Chua Cá',
    thumbnail: 'assets/images/canhchua.jpg',
    image: 'assets/images/canhchua.jpg',
    description:
    'Canh chua cá với vị chua thanh, ngọt tự nhiên, nhiều rau thơm.',
    ingredients: [
      '1 con cá lóc hoặc cá basa',
      'Cà chua, thơm, bạc hà, giá',
      'Me chua, rau thơm',
      'Gia vị, nước mắm'
    ],
    steps: [
      'Nấu nước với me chua, thêm cà chua và thơm.',
      'Cho cá vào nấu chín.',
      'Thêm rau, nêm nếm vừa ăn.'
    ],
    duration: 30,
    difficulty: 'Dễ',
  ),
  Recipe(
    id: 'r9',
    title: 'Bò Lúc Lắc',
    thumbnail: 'assets/images/boluclac.jpg',
    image: 'assets/images/boluclac.jpg',
    description:
    'Thịt bò cắt khối vuông, xào nhanh với ớt chuông và hành tây, mềm thơm.',
    ingredients: [
      '300g thịt bò thăn',
      'Ớt chuông, hành tây',
      'Tỏi băm',
      'Xì dầu, dầu hào, tiêu'
    ],
    steps: [
      'Ướp bò với gia vị.',
      'Xào bò trên lửa lớn cho săn lại.',
      'Thêm rau củ, đảo nhanh tay rồi tắt bếp.'
    ],
    duration: 25,
    difficulty: 'Trung bình',
  ),
  Recipe(
    id: 'r10',
    title: 'Chè Ba Màu',
    thumbnail: 'assets/images/chebamau.jpg',
    image: 'assets/images/chebamau.jpg',
    description:
    'Chè ba màu mát lạnh với đậu, thạch và nước cốt dừa béo ngậy.',
    ingredients: [
      'Đậu đỏ, đậu xanh',
      'Thạch, đá bào',
      'Nước cốt dừa, đường'
    ],
    steps: [
      'Nấu chín từng loại đậu.',
      'Cho đậu, thạch vào ly theo lớp.',
      'Rưới nước cốt dừa, thêm đá bào.'
    ],
    duration: 50,
    difficulty: 'Dễ',
  ),
];
