<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

class CreatePostsTable extends Migration {
    /**
     * Run the migrations.
     *
     * @return void
     */
    public function up() {
        Schema::create( 'posts', function ( Blueprint $table ) {
            $table->id( 'ID' );
            $table->bigInteger( 'post_author' );
            $table->dateTime( 'post_date' )->default( '0000-00-00 00:00:00' );
            $table->dateTime( 'post_date_gmt' )->default( '0000-00-00 00:00:00' );
            $table->longText( 'post_content' );
            $table->string( 'post_title' );
            $table->string( 'post_excerpt' );
            $table->string( 'post_status', 20 )->default( 'publish ' );
            $table->string( 'comment_status', 20 )->default( 'open' );
            $table->string( 'ping_status', 20 )->default( 'open' );
            $table->string( 'post_password' )->default( '' );
            $table->string( 'post_name', 200 )->default( '' );
            $table->text( 'to_ping' );
            $table->text( 'pinged' );
            $table->dateTime( 'post_modified' )
                  ->default( '0000-00-00 00:00:00' );
            $table->dateTime( 'post_modified_gmt' )
                  ->default( '0000-00-00 00:00:00' );
            $table->longText( 'post_content_filtered' );
            $table->bigInteger( 'post_parent' )->default( 0 );
            $table->string( 'guid' )->default( '' );
            $table->integer( 'menu_order' )->default( 0 );
            $table->string( 'post_type', 20 )->default( 'post' );
            $table->string( 'post_mime_type', 100 )->default( '' );
            $table->bigInteger( 'comment_count' )->default( 0 );
        } );
    }

    /**
     * Reverse the migrations.
     *
     * @return void
     */
    public function down() {
        Schema::dropIfExists( 'posts' );
    }
}
