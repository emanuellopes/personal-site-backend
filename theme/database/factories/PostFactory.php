<?php

namespace Database\Factories;

use App\Models\Post;
use App\Models\User;
use Illuminate\Database\Eloquent\Factories\Factory;

class PostFactory extends Factory {
    /**
     * The name of the factory's corresponding model.
     *
     * @var string
     */
    protected $model = Post::class;

    private function get_random_gutenberg_article() {
        return array(
            '<!-- wp:paragraph -->
<p>Artigo test1</p>
<!-- /wp:paragraph -->

<!-- wp:paragraph -->
<p>teste 2</p>
<!-- /wp:paragraph -->',
            '<!-- wp:paragraph -->
<p>Artigo test2</p>
<!-- /wp:paragraph -->

<!-- wp:paragraph -->
<p>teste 3</p>
<!-- /wp:paragraph -->'
        );
    }


    /**
     * Define the model's default state.
     *
     * @return array
     */
    public function definition() {
        return [
            'post_author'           => 1,
            'post_date'             => $date
                = $this->faker->dateTimeBetween( '-100 days', 'now', 'GMT' ),
            'post_date_gmt'         => $date,
            'post_content'          => $this->faker->randomElement( $this->get_random_gutenberg_article() ),
            'post_title'            => $this->faker->text( 120 ),
            'post_excerpt'          => $this->faker->text( 50 ),
            'post_status'           => $this->faker->randomElement( [
                'draft',
                'publish',
                'private'
            ] ),
            'comment_status'        => $this->faker->randomElement( [
                'open',
                'closed'
            ] ),
            'ping_status'           => $this->faker->randomElement(['open', 'closed']),
            'post_password'         => '',
            'post_name'             => $this->faker->slug,
            'to_ping'               => '',
            'pinged'                => '',
            'post_modified'         => $this->faker->dateTimeBetween( '-100 days', 'now', 'GMT' ),
            'post_modified_gmt'     => $this->faker->dateTimeBetween( '-100 days', 'now', 'GMT' ),
            'post_content_filtered' => $this->faker->randomNumber( 1 ),
            'post_parent'           => 0,
//            'guid'                  => $this->faker->,
//            'menu_order'            => $this->faker->randomNumber( 1 ),
            'post_type'             => $this->faker->randomElement(['post', 'page']),
//            'post_mime_type'        => $this->faker->randomNumber( 1 ),
//            'comment_count'         => $this->faker->randomNumber( 1 ),
        ];
    }
}
