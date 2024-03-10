import curses
import string
import random
import math
import time
import sys
import datetime

class NetworkNemesis:
    def __init__(self, stdscr):
        self.LOG_FILEPATH = "log.txt"
        self.DATA_FILEPATH = "data.txt"
        self.MAX_WORDS = 60
        self.MATRIX_COLS = 6
        self.SECONDS_PER_ROUND = 60
        self.SECONDS_PENALTY = 5

        self.stdscr = stdscr
        self.height, self.width = stdscr.getmaxyx()
        self.passphrase = self.get_passphrase()
        self.words = self.get_words()
        self.matrix = self.gen_matrix()
        self.cursor_position = [0, 0]
        self.rounds = len(self.passphrase)
        self.current_round = 0
        self.selected_word = None
        self.used_words = []
        self.known_chars = []
        self.timer = None
        self.game_over = False

        self.log(self.passphrase)
        self.run()

    def log(self, message):
        with open(self.LOG_FILEPATH, "a") as file:
            file.write(f"{datetime.datetime.now()} {str(message)}\n")

    def get_passphrase(self):
        with open(self.DATA_FILEPATH, "r") as file:
            lines = file.read().splitlines()
        
        passphrase = random.choice(lines).upper().split(" ")

        return passphrase

    def get_words(self):
        words = []

        # Load all words.
        with open(self.DATA_FILEPATH, "r") as file:
            lines = file.read().splitlines()

            for line in lines:
                words = list(set(words) | set(line.upper().split(" ")))

        # Remove the passphrase words for word list.
        for word in set(self.passphrase):
            words.remove(word)

        words = self.sample_words_by_distribution(words, self.MAX_WORDS - len(self.passphrase))

        # Convert two random words to leet speech.
        for _ in range(2):
            index = random.randint(0, len(words) - 1)
            words[index] = self.to_leet_speech(words[index])

        # Re-add passphrase words.
        words.extend(self.passphrase)

        return words

    def get_input(self, key):
        # Exit the program.
        if key == 27:
            curses.endwin() 
            sys.exit()

        # Disable input on game over.
        if self.game_over:
            return

        # Cursor movement.
        if key in [curses.KEY_UP, curses.KEY_DOWN, curses.KEY_LEFT, curses.KEY_RIGHT]:
            if key == curses.KEY_UP:
                self.set_cursor_position((0, -1))
            if key == curses.KEY_DOWN:
                self.set_cursor_position((0, 1))
            elif key == curses.KEY_LEFT:
                self.set_cursor_position((-1, 0))
            elif key == curses.KEY_RIGHT:
                self.set_cursor_position((1, 0))

            return
        
        # Select the word.
        if key in [curses.KEY_ENTER, ord('\n'), ord(' ')]:
            self.activate()

            return

    def set_cursor_position(self, vector):
        direction_x, direction_y = vector
        cursor_y, cursor_x = self.cursor_position

        y = (cursor_y + direction_y) % len(self.matrix)
        x = (cursor_x + direction_x) % len(self.matrix[0])

        self.cursor_position = [y, x]

    def sample_words_by_distribution(self, words, max_words):
        # Group words by their length.
        words_by_length = {}
        for word in words:
            words_by_length.setdefault(len(word), []).append(word)

        # Calculate probability distribution
        words_distribution = {}
        total_length = sum(len(wordlist) for wordlist in words_by_length.values())
        for length, wordlist in words_by_length.items():
            words_distribution[length] = len(wordlist) / total_length

        # Get words based on probability distribution.
        sampled_words = []
        for length, percent in words_distribution.items():
            expected_words = percent * max_words
            guaranteed_words = int(expected_words)  # Guaranteed number of words.

            # Determine if an additional word should be included based on the fractional part.
            if random.random() < (expected_words - guaranteed_words):
                guaranteed_words += 1

            # Ensure we have enough words of this length to sample
            if guaranteed_words > 0 and length in words_by_length:
                words_to_sample = min(guaranteed_words, len(words_by_length[length]))
                sampled_words.extend(random.sample(words_by_length[length], words_to_sample))

        # Adjust if the total sampled words exceed max_words due to rounding
        if len(sampled_words) > max_words:
            sampled_words = random.sample(sampled_words, max_words)

        # Fill the rest of the words randomly if short due to rounding errors, ensuring unique selection.
        all_words = [word for word in words if word not in sampled_words]
        while len(sampled_words) < max_words and all_words:
            new_word = random.choice(all_words)
            sampled_words.append(new_word)
            all_words.remove(new_word)

        return sampled_words

    def to_leet_speech(self, word):
        leet_map = {
            'A': '4',
            'B': '8',
            'E': '3',
            'G': '6',
            'I': '1',
            'L': '1',
            'O': '0',
            'S': '5',
            'T': '7',
            'Z': '2'
        }
        
        return ''.join(leet_map.get(letter, letter) for letter in word)
    
    def is_leet_speech(self, word):
        return any(char.isdigit() for char in word)

    def gen_cracked_passphrase(self):
        cracked_parts = []
        
        for idx, word in enumerate(self.passphrase):
            if idx < self.current_round:
                cracked_parts.append(word)
            else:
                encrypted_word = "".join([random.choice(string.ascii_uppercase) for _ in range(len(word))])
                cracked_parts.append(encrypted_word)
        
        cracked_passphrase = " ".join(cracked_parts)
        return cracked_passphrase

    def gen_matrix(self):
        # Copy and shuffle the words.
        words =  self.words.copy()
        self.log(words)
        random.shuffle(words)

        # Build the matrix.
        matrix = []
        index = 0
        cols = self.MATRIX_COLS
        rows = math.ceil(len(words) / cols)

        for _ in range(rows):
            row = []

            for _ in range(cols):
                row.append(words[index])
                index += 1

            matrix.append(row)

        return matrix

    def display_cracked_password(self, y):
        cracked_passphrase = self.gen_cracked_passphrase()
        self.stdscr.addstr(y, 0, f"Passphrase: {cracked_passphrase}")

    def display_timer(self, y):
        elapsed_time = time.time() - self.timer
        remaining_time = max(self.SECONDS_PER_ROUND - elapsed_time, 0)
        
        
        seconds = int(remaining_time)
        hundredths = int((remaining_time % 1) * 100)
        timer_str = f"Time Remaining: {seconds:02d}.{hundredths:02d}"
        self.stdscr.addstr(y, 0, timer_str)

    def display_matrix(self, y):
        col_space = 2
        col_widths = [max(len(row[i]) for row in self.matrix if i < len(row)) + 4 for i in range(self.MATRIX_COLS)]
        
        for row_idx, row in enumerate(self.matrix):
            x = 0

            for col_idx, word in enumerate(row):
                byte = "".join(random.choice("0123456789abcdef") for _ in range(2))
                byte_and_open_paren = f"{byte}("
                close_paren = ")"
                
                # Print the byte and opening parenthesis with the default color.
                self.stdscr.addstr(y, x, byte_and_open_paren, curses.color_pair(1))

                word_start_x = x + len(byte_and_open_paren)
                is_leet = self.is_leet_speech(word)

                # Determine the color for the entire word based on its status and content
                if [row_idx, col_idx] == self.cursor_position:
                    entire_word_color = curses.color_pair(4) if is_leet else curses.color_pair(2)
                elif word in self.used_words:
                    entire_word_color = curses.color_pair(5) if is_leet else curses.color_pair(6)
                else:
                    entire_word_color = None

                # Print each character of the word, applying the appropriate color.
                for char_idx, char in enumerate(word):
                    if entire_word_color:
                        char_color = entire_word_color
                    else:
                        char_color = curses.color_pair(3) if char in self.known_chars else curses.color_pair(1)
                    
                    self.stdscr.addstr(y, word_start_x + char_idx, char, char_color)

                self.stdscr.addstr(y, word_start_x + len(word), close_paren, curses.color_pair(1))

                x += col_widths[col_idx] + col_space
            
            y += 1

    def activate(self):
        self.selected_word = self.matrix[self.cursor_position[0]][self.cursor_position[1]]

        if self.selected_word == self.passphrase[self.current_round]:
            self.current_round += 1
            self.reset()

            if self.current_round >= len(self.passphrase):
                self.game_over = True
        else:
            # Update used words.
            used_words = self.used_words.copy()
            used_words.append(self.selected_word)
            self.used_words = list(set(used_words))

            # Invoke timer penalty for incorrect guess.
            if self.selected_word != self.passphrase[self.current_round]:
                elapsed_time = time.time() - self.timer
                remaining_time = max(self.SECONDS_PER_ROUND - elapsed_time, 0)
                penalty_time = max(remaining_time - self.SECONDS_PENALTY, 0)
                
                self.timer = time.time() - (self.SECONDS_PER_ROUND - penalty_time)

            # Update known chars.
            for char in self.selected_word:
                if char in self.passphrase[self.current_round] and char not in self.known_chars:
                    self.known_chars.append(char)

    def reset(self):
        self.matrix = self.gen_matrix()
        self.cursor_position = [0, 0]
        self.selected_word = None
        self.used_words = []
        self.known_chars = []
        self.timer = time.time()

    def run(self):
        curses.curs_set(0)
        self.stdscr.nodelay(True)

        if curses.has_colors():
            curses.start_color()
            curses.use_default_colors()
        
            # Init color
            curses.init_pair(1, curses.COLOR_GREEN, curses.COLOR_BLACK)
            curses.init_pair(2, curses.COLOR_BLACK, curses.COLOR_WHITE)
            curses.init_pair(3, curses.COLOR_WHITE, curses.COLOR_BLACK)
            curses.init_pair(4, curses.COLOR_BLACK, curses.COLOR_RED)
            curses.init_pair(5, curses.COLOR_RED, curses.COLOR_BLACK)
            curses.init_pair(6, 59, curses.COLOR_BLACK)
            self.stdscr.bkgd(" ", curses.color_pair(1))

        self.timer = time.time()

        while True:
            self.stdscr.clear()

            self.display_cracked_password(1)
            self.display_timer(2)
            self.display_matrix(4)

            self.get_input(self.stdscr.getch())
            
            elapsed_time = time.time() - self.timer
            if elapsed_time >= self.SECONDS_PER_ROUND:
                self.reset()

            self.stdscr.refresh()
            
            time.sleep(0.05)


if __name__ == "__main__":
    curses.wrapper(NetworkNemesis)