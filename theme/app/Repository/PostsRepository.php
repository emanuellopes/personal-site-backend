<?php

namespace App\Repository;

use App\Repository\Contracts\PostsRepository as PostsContract;

class PostsRepository implements PostsContract {

    public function getAllPosts(): array {
        return get_posts();
    }
}
