import random

print("Welcome to the Number Guessing Game!")
print("-------------------------------------")

gameboard = [['1', '2', '3'], ['4', '5', '6'], ['7', '8', '9']]
rows = 3
cols = 3

def printgameboard():
    for x in range(rows):
        print("\n+----+----+----+")
        print(" |", end="")
        for y in range(cols):
            print("", gameboard[x][y], end=" |")
    print("\n+----+----+----+")

def modifyArray(num, turn):
    for i in range(rows):
        for j in range(cols):
            if gameboard[i][j] == str(num):
                gameboard[i][j] = turn
                return

def checkForWinner(gameBoard):
    # Check rows, columns, and diagonals
    for i in range(3):
        if gameBoard[i][0] == gameBoard[i][1] == gameBoard[i][2]:
            print(gameBoard[i][0], "has won!")
            return gameBoard[i][0]
        if gameBoard[0][i] == gameBoard[1][i] == gameBoard[2][i]:
            print(gameBoard[0][i], "has won!")
            return gameBoard[0][i]
    if gameBoard[0][0] == gameBoard[1][1] == gameBoard[2][2]:
        print(gameBoard[0][0], "has won!")
        return gameBoard[0][0]
    if gameBoard[0][2] == gameBoard[1][1] == gameBoard[2][0]:
        print(gameBoard[0][2], "has won!")
        return gameBoard[0][2]
    return "N"

turnCounter = 0

while True:
    printgameboard()
    if turnCounter % 2 == 0:
        numberPicked = int(input("\nChoose a number[1-9]: "))
        if numberPicked not in range(1, 10):
            print("Invalid number, please try again")
            continue
        modifyArray(numberPicked, 'X')
    else:
        cpuChoice = random.randint(1, 9)
        modifyArray(cpuChoice, 'O')
        print("Computer chose:", cpuChoice)
    winner = checkForWinner(gameboard)
    if winner != "N":
        print(winner, "has won!!! Game Over!!!")
        break
    turnCounter += 1
    if turnCounter == 9:
        print("It's a tie! Game Over!!!")
        break