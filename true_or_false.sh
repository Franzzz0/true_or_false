#!/usr/bin/bash
curl -s -o ID_card.txt http://127.0.0.1:8000/download/file.txt
login=$(cut -d '"' -f 4 ID_card.txt)
pass=$(cut -d '"' -f 8 ID_card.txt)
$(curl -s -c cookie.txt -u "$login:$pass" http://127.0.0.1:8000/login)
correct_responses=( "Perfect!" "Awesome!" "You are a genius!" "Wow!" "Wonderful!" )
game () {
    echo "What is your name?"
    read player_name
    RANDOM=4096
    points=0
    correct_answers=0
    while true; do
        item=$(curl --cookie cookie.txt http://127.0.0.1:8000/game)
        question=$(echo "$item" | sed 's/.*"question": *"\{0,1\}\([^,"]*\)"\{0,1\}.*/\1/')
        answer=$(echo "$item" | sed 's/.*"answer": *"\{0,1\}\([^,"]*\)"\{0,1\}.*/\1/')
        echo $question
        echo "True or False?"
        read player_answer
        if [ "$player_answer,," = "$answer,," ]; then
            echo "${correct_responses[$((RANDOM % 5))]}"
            ((points+=10))
            ((correct_answers++))
        else
            echo "Wrong answer, sorry!
$player_name you have $correct_answers correct answer(s).
Your score is $points points."
            date=$(date +%F)
            echo "User: $player_name, Score: $points, Date: $date" >> scores.txt
            break
        fi
    done
}
scores() {
    if [ -s scores.txt ]; then
        echo "Player scores"
        cat scores.txt
    else
        echo "File not found or no scores in it!"
    fi
}
reset_scores() {
    if [ -e scores.txt ]; then
        rm scores.txt
        echo "File deleted successfully!"
    else
        echo "File not found or no scores in it!"
    fi
}
echo "Welcome to the True or False Game!"
while true; do
    echo "
0. Exit
1. Play a game
2. Display scores
3. Reset scores
Enter an option:"
    read input
    case "$input" in
        1)
            game;;
        2)
            scores;;
        3)
            reset_scores;;
        0)
            echo "See you later!"
            break;;
        *)
            echo "Invalid option!";;
    esac
done
