<?php
return [
    'model' => env('SYSTEMONE_MODEL'),
    'vision' => (bool) env('SYSTEMONE_VISION', false),
    'image_format' => env('SYSTEMONE_IMAGE_FORMAT', 'base64'),
];
