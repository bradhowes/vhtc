//
//  LoremIpsum.swift
//  BRHSpringyCollectionView
//
//  Created by Brad Howes on 12/28/16.
//  Copyright © 2016 Brad Howes. All rights reserved.
//
//  Basic idea and much of the API borrowed from the excellent "LoremIpsum" utility by Lukas Kubanek
//  (https://github.com/lukaskubanek/LoremIpsum). Where Lukas' implemntation was in Objective C, this is
//  Swift.
//

import Foundation
import CoreGraphics
import UIKit

fileprivate extension String {
    func split() -> [String] {
        return self.components(separatedBy: " ")
    }
}

fileprivate extension RandomGenerator {
    mutating func pick<T>(_ seq: Array<T>) -> T {
        precondition(seq.count > 0, "attempt to pick from empty array")
        return seq[Int(randomHalfOpen() * Double(seq.count))] }
}

public class LoremIpsumGenerator {

    public static let kWords: [String] = "alias consequatur aut perferendis sit voluptatem accusantium doloremque aperiam eaque ipsa quae ab illo inventore veritatis et quasi architecto beatae vitae dicta sunt explicabo aspernatur aut odit aut fugit sed quia consequuntur magni dolores eos qui ratione voluptatem sequi nesciunt neque dolorem ipsum quia dolor sit amet consectetur adipisci velit sed quia non numquam eius modi tempora incidunt ut labore et dolore magnam aliquam quaerat voluptatem ut enim ad minima veniam quis nostrum exercitationem ullam corporis nemo enim ipsam voluptatem quia voluptas sit suscipit laboriosam nisi ut aliquid ex ea commodi consequatur quis autem vel eum iure reprehenderit qui in ea voluptate velit esse quam nihil molestiae et iusto odio dignissimos ducimus qui blanditiis praesentium laudantium totam rem voluptatum deleniti atque corrupti quos dolores et quas molestias excepturi sint occaecati cupiditate non provident sed ut perspiciatis unde omnis iste natus error similique sunt in culpa qui officia deserunt mollitia animi id est laborum et dolorum fuga et harum quidem rerum facilis est et expedita distinctio nam libero tempore cum soluta nobis est eligendi optio cumque nihil impedit quo porro quisquam est qui minus id quod maxime placeat facere possimus omnis voluptas assumenda est omnis dolor repellendus temporibus autem quibusdam et aut consequatur vel illum qui dolorem eum fugiat quo voluptas nulla pariatur at vero eos et accusamus officiis debitis aut rerum necessitatibus saepe eveniet ut et voluptates repudiandae sint et molestiae non recusandae itaque earum rerum hic tenetur a sapiente delectus ut aut reiciendis voluptatibus maiores doloribus asperiores repellat".split()

    public static let kFirstNames: [String] = "Judith Angelo Margarita Kerry Elaine Lorenzo Justice Doris Raul Liliana Kerry Elise Ciaran Johnny Moses Davion Penny Mohammed Harvey Sheryl Hudson Brendan Brooklynn Denis Sadie Trisha Jacquelyn Virgil Cindy Alexa Marianne Giselle Casey Alondra Angela Katherine Skyler Kyleigh Carly Abel Adrianna Luis Dominick Eoin Noel Ciara Roberto Skylar Brock Earl Dwayne Jackie Hamish Sienna Nolan Daren Jean Shirley Connor Geraldine Niall Kristi Monty Yvonne Tammie Zachariah Fatima Ruby Nadia Anahi Calum Peggy Alfredo Marybeth Bonnie Gordon Cara John Staci Samuel Carmen Rylee Yehudi Colm Beth Dulce Darius inley Javon Jason Perla Wayne Laila Kaleigh Maggie Don Quinn Collin Aniya Zoe Isabel Clint Leland Esmeralda Emma Madeline Byron Courtney Vanessa Terry Antoinette George Constance Preston Rolando Caleb Kenneth Lynette Carley Francesca Johnnie Jordyn Arturo Camila Skye Guy Ana Kaylin Nia Colton Bart Brendon Alvin Daryl Dirk Mya Pete Joann Uriel Alonzo Agnes Chris Alyson Paola Dora Elias Allen Jackie Eric Bonita Kelvin Emiliano Ashton Kyra Kailey Sonja Alberto Ty Summer Brayden Lori Kelly Tomas Joey Billie Katie Stephanie Danielle Alexis Jamal Kieran Lucinda Eliza Allyson Melinda Alma Piper Deana Harriet Bryce Eli Jadyn Rogelio Orlaith Janet Randal Toby Carla Lorie Caitlyn Annika Isabelle inn Ewan Maisie Michelle Grady Ida Reid Emely Tricia Beau Reese Vance Dalton Lexi Rafael Makenzie Mitzi Clinton Xena Angelina Kendrick Leslie Teddy Jerald Noelle Neil Marsha Gayle Omar Abigail Alexandra Phil Andre Billy Brenden Bianca Jared Gretchen Patrick Antonio Josephine Kyla Manuel Freya Kellie Tonia Jamie Sydney Andres Ruben Harrison Hector Clyde Wendell Kaden Ian Tracy Cathleen Shawn".split()

    public static let kLastNames: [String] = "Chung Chen Melton Hill Puckett Song Hamilton Bender Wagner McLaughlin McNamara Raynor Moon Woodard Desai Wallace Lawrence Griffin Dougherty Powers May Steele Teague Vick Gallagher Solomon Walsh Monroe Connolly Hawkins Middleton Goldstein Watts Johnston Weeks Wilkerson Barton Walton Hall Ross Chung Bender Woods Mangum Joseph Rosenthal Bowden Barton Underwood Jones Baker Merritt Cross Cooper Holmes Sharpe Morgan Hoyle Allen Rich Rich Grant Proctor Diaz Graham Watkins Hinton Marsh Hewitt Branch Walton O'Brien Case Watts Christensen Parks Hardin Lucas Eason Davidson Whitehead Rose Sparks Moore Pearson Rodgers Graves Scarborough Sutton Sinclair Bowman Olsen Love McLean Christian Lamb James Chandler Stout Cowan Golden Bowling Beasley Clapp Abrams Tilley Morse Boykin Sumner Cassidy Davidson Heath Blanchard McAllister McKenzie Byrne Schroeder Griffin Gross Perkins Robertson Palmer Brady Rowe Zhang Hodge Li Bowling Justice Glass Willis Hester Floyd Graves Fischer Norman Chan Hunt Byrd Lane Kaplan Heller May Jennings Hanna Locklear Holloway Jones Glover Vick O'Donnell Goldman McKenna Starr Stone McClure Watson Monroe Abbott Singer Hall Farrell Lucas Norman Atkins Monroe Robertson Sykes Reid Chandler Finch Hobbs Adkins Kinney Whitaker Alexander Conner Waters Becker Rollins Love Adkins Black Fox Hatcher Wu Lloyd Joyce Welch Matthews Chappell MacDonald Kane Butler Pickett Bowman Barton Kennedy Branch Thornton McNeill Weinstein Middleton Moss Lucas Rich Carlton Brady Schultz Nichols Harvey Stevenson Houston Dunn West O'Brien Barr Snyder Cain Heath Boswell Olsen Pittman Weiner Petersen Davis Coleman Terrell Norman Burch Weiner Parrott Henry Gray Chang McLean Eason Weeks Siegel Puckett Heath Hoyle Garrett Neal Baker Goldman Shaffer Choi Carver".split()

    public static let kEmailDomains: [String] = "gmail.com yahoo.com hotmail.com email.com live.com me.com mac.com aol.com fastmail.com mail.com".split()

    public static let kDomains: [String] = "twitter.com google.com youtube.com wordpress.org adobe.com blogspot.com godaddy.com wikipedia.org wordpress.com yahoo.com linkedin.com amazon.com flickr.com w3.org apple.com myspace.com tumblr.com digg.com microsoft.com vimeo.com pinterest.com qq.com stumbleupon.com youtu.be addthis.com miibeian.gov.cn delicious.com baidu.com feedburner.com bit.ly".split()

    public static let kEmailSeparators: [String] = ["", "-", "_", "."]

    // source: http://www.kevadamson.com/talking-of-design/article/140-alternative-characters-to-lorem-ipsum
    public static let kTweets = [
        "Far away, in a forest next to a river beneath the mountains, there lived a small purple otter called Philip. Philip likes sausages. The End.",
        "He liked the quality sausages from Marks & Spencer but due to the recession he had been forced to shop in a less desirable supermarket. End.",
        "He awoke one day to find his pile of sausages missing. Roger the greedy boar with human eyes, had skateboarded into the forest & eaten them!"
    ]

    private var randomGenerator: RandomGenerator

    public init(randomGenerator: RandomGenerator = Xoroshiro()) {
        self.randomGenerator = randomGenerator
    }

    public func randomInt(lowerBound: Int, upperBound: Int) -> Int {
        precondition(lowerBound <= upperBound, "invalid bounds")
        return Int(randomGenerator.randomClosed() * Double(upperBound - lowerBound)) + lowerBound
    }

    public func word() -> String {
        return words(count: 1)
    }

    public func wordCollection(count: Int) -> [String] {
        precondition(count > 0, "invalid count")
        return (0..<count).map { _ in randomGenerator.pick(LoremIpsumGenerator.kWords) }
    }

    public func words(count: Int) -> String {
        return wordCollection(count: count).joined(separator: " ")
    }

    public func sentence() -> String {
        return sentences(count: 1)
    }

    public func sentences(count: Int) -> String {
        precondition(count > 0, "invalid count")
        return (0..<count).map { _ in ([word().capitalized] + wordCollection(count: randomInt(lowerBound: 3, upperBound: 15)))
            .joined(separator: " ").appending(".") }.joined(separator: " ")
    }

    public func paragraph() -> String {
        return paragraphs(count: 1)
    }

    public func paragraphs(count: Int) -> String {
        precondition(count > 0, "invalid count")
        return (0..<count).map { _ in sentences(count: randomInt(lowerBound: 3, upperBound: 9)) }
            .joined(separator: "\n")
    }

    public func title() -> String {
        return wordCollection(count: randomInt(lowerBound: 3, upperBound: 7)).map { $0.capitalized }
            .joined(separator:" ")
    }

    public func name() -> String {
        return "\(self.firstName()) \(self.lastName())"
    }

    public func firstName() -> String {
        return randomGenerator.pick(LoremIpsumGenerator.kFirstNames)
    }

    public func lastName() -> String {
        return randomGenerator.pick(LoremIpsumGenerator.kLastNames)
    }

    public func email() -> String {
        let domain = randomGenerator.pick(LoremIpsumGenerator.kEmailDomains)
        let delimiter = randomGenerator.pick(LoremIpsumGenerator.kEmailSeparators)
        let addressComponents: [String] = {
            switch randomInt(lowerBound: 1, upperBound: 3) {
            case 1: return [lastName()]
            case 2: return [firstName(), lastName()]
            default: return [firstName(), firstName(), lastName()]
            }
        }()
        return addressComponents.joined(separator: delimiter).lowercased() + "@" + domain
    }

    public func tweet() -> String {
        return randomGenerator.pick(LoremIpsumGenerator.kTweets)
    }

    public func date() -> Date {
        return Date().addingTimeInterval(TimeInterval(randomInt(lowerBound: 60, upperBound: 60 * 60 * 24 * 7) * -1))
    }

    public func phoneNumber() -> String {
        return "+18005551212"
    }

    public func imagePlaceholder(size: CGSize) -> UIImage {
        let color: UIColor = {
            let red = CGFloat(randomGenerator.randomClosed())
            let green = CGFloat(randomGenerator.randomClosed())
            let blue = CGFloat(randomGenerator.randomClosed())
            return UIColor(red: red, green: green, blue: blue, alpha: 1.0)
        }()
        return imagePlaceholder(size: size, color: color)
    }

    public func imagePlaceholder(size: CGSize, color: UIColor) -> UIImage {
        UIGraphicsBeginImageContextWithOptions(size, false, 0.0)
        defer { UIGraphicsEndImageContext() }

        guard let context = UIGraphicsGetCurrentContext() else { fatalError("invalid graphics context") }

        context.setFillColor(color.cgColor)
        context.fill(CGRect(origin: CGPoint.zero, size: size))

        guard let image = UIGraphicsGetImageFromCurrentImageContext() else { fatalError("null UIImage from context") }
        return image
    }

    public func avatar() -> UIImage {
        let index = randomInt(lowerBound: 1, upperBound: 4)
        let name = "avatar\(index)"
        let image = UIImage(named: name, in: Bundle(for: LoremIpsumGenerator.self), compatibleWith: nil)
        return image!
    }

    public enum ImageService: String {
        case loremPixel = "http://lorempixel.com/%d/%d"
        case loremPixelGrey = "http://lorempixel.com/g/%d/%d"
        case dummyImage = "http://dummyimage.com/%dx%d"
        case placehold = "http://placehold.it/%dx%d"
        static let all: [ImageService] = [.loremPixel, .loremPixelGrey, .dummyImage, .placehold]
    }

    public func urlforAsyncImagePlaceholder(size: CGSize, service: ImageService) -> URL? {
        let source = service.rawValue
        let url = String.localizedStringWithFormat(source, Int(size.width), Int(size.height))
        return URL(string: url)
    }

    public func urlforAsyncImagePlaceholder(size: CGSize) -> URL? {
        return urlforAsyncImagePlaceholder(size: size, service: randomGenerator.pick(ImageService.all))
    }

    public func asyncImagePlaceholder(size: CGSize, service: ImageService, completion: @escaping (UIImage?)->()) {
        guard let url = urlforAsyncImagePlaceholder(size: size, service: service) else {
            completion(nil)
            return
        }

        let config = URLSessionConfiguration.ephemeral
        let session = URLSession(configuration: config, delegate: nil, delegateQueue: OperationQueue.main)
        let request = URLRequest(url: url)
        session.dataTask(with: request) { data, response, error in
            print(data ?? "nil data")
            print(response ?? "nil response")
            print(error ?? "nil error")
            if error == nil {
                if data != nil {
                    completion(UIImage(data: data!))
                    return
                }
            }
            completion(UIImage())
        }.resume()
    }

    public func asyncImagePlaceholder(size: CGSize, completion: @escaping (UIImage?)->()) {
        asyncImagePlaceholder(size: size, service: randomGenerator.pick(ImageService.all), completion: completion)
    }
}
