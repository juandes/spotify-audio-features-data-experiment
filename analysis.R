require(ggplot2)
require(reshape2)

# To avoid scientific notation
options(scipen=999)
df.1 <- read.csv("me.csv")
df.2 <- read.csv("her.csv")

# NOTE: Everything df.1 is me, and df.2 is her

df.1 <- df.1[complete.cases(df.1),]
df.2 <- df.2[complete.cases(df.2),]

df.1.mean <- sapply(df.1[1:13],mean)
df.1.sd <- sapply(df.1[1:13],sd)

df.1.stats <- data.frame(feature=colnames(df.1[1:13]), mean = df.1.mean,
                         sd = df.1.sd, type = c('i','i', 'e', 'i', 'i', 'i',
                                                'e', 'i', 'e', 'e', 'e', 'i', 'e'))
rownames(df.1.stats) <- NULL

df.2.mean <- sapply(df.2[1:13],mean)
df.2.sd <- sapply(df.2[1:13],sd)

df.2.stats <- data.frame(feature=colnames(df.2[1:13]), mean = df.2.mean,
                         sd = df.2.sd, type = c('i','i', 'e', 'i', 'i', 'i',
                                                'e', 'i', 'e', 'e', 'e', 'i', 'e'))
rownames(df.2.stats) <- NULL
print(df.1.stats)


# Implicit features
# Mean of features
df.1.i <- df.1.stats[df.1.stats$type == 'i',]

ggplot(df.1.i, aes(x = reorder(feature, -mean), y = mean)) +
  geom_bar(stat='identity', fill = '#00BFC4') +
  theme(axis.text = element_text(colour = 'black')) +
  ggtitle("Mean value of audio features of my playlist") +
  xlab("Features") +
  ylab("Mean") +
  theme(axis.text.x = element_text(angle = 90, hjust = 1))

df.2.i <- df.2.stats[df.2.stats$type == 'i',]

ggplot(df.2.i, aes(x = reorder(feature, -mean), y = mean)) +
  geom_bar(stat='identity', fill = '#F8766D') +
  theme(axis.text = element_text(colour = 'black')) +
  ggtitle("Mean value of audio features of her playlist") +
  xlab("Features") +
  ylab("Mean") +
  theme(axis.text.x = element_text(angle = 90, hjust = 1))

df.mean.difference <- data.frame(feature = df.1.i$feature,
                                 difference = df.1.i$mean - df.2.i$mean)

df.mean.difference$who <- ifelse(df.mean.difference$difference > 0, 'me', 'her')

ggplot(df.mean.difference, aes(x = reorder(feature, -difference), 
                               y = difference, fill = who)) +
  geom_bar(stat='identity') +
  ggtitle("Difference between audio features mean of my songs and hers") +
  xlab("Feature") +
  ylab("Difference") +
  theme(axis.text.x = element_text(angle = 90, hjust = 1))

# Sparsity, or variety of playlists
ggplot(df.1.i, aes(x = reorder(feature, -sd), y = sd)) +
  geom_bar(stat='identity', fill = '#00BFC4') +
  theme(axis.text = element_text(colour = 'black')) +
  ggtitle("Standard deviation of the audio features scores of my playlist") +
  xlab("Feature")+
  ylab("Standard Deviation") +
  theme(axis.text.x = element_text(angle = 90, hjust = 1))

sum(df.1.i$sd)

ggplot(df.2.i, aes(x = reorder(feature, -sd), y = sd)) +
  geom_bar(stat='identity', fill = '#F8766D') +
  theme(axis.text = element_text(colour = 'black')) +
  ggtitle("Standard deviation of the audio features scores of her playlist") +
  xlab("Feature")+
  ylab("Standard Deviation") +
  theme(axis.text.x = element_text(angle = 90, hjust = 1))

sum(df.2.i$sd)

df.1.long <- df.1[ ,c('energy', 'liveness', 'speechiness', 
                      'acousticness', 'instrumentalness',
                      'danceability', 'valence')]
df.1.long <- melt(df.1.long)

ggplot(df.1.long, aes(factor(variable), value)) + geom_boxplot() 

df.2.long <- df.2[ ,c('energy', 'liveness', 'speechiness', 
                      'acousticness', 'instrumentalness',
                      'danceability', 'valence')]
df.2.long <- melt(df.2.long)

ggplot(df.2.long, aes(factor(variable), value)) + geom_boxplot() 

## Correlations
df.1.cor <- cor(df.1[c(1,2,4:6,8,12)])
ggplot(df.1, aes(x = energy, y = danceability)) +
  geom_point() +
  geom_smooth(method = "loess", se = FALSE) +
  ggtitle("Correlation between danceability and energy (me)")

ggplot(df.1, aes(x = energy, y = acousticness)) +
  geom_point() +
  geom_smooth(method = "loess", se = FALSE) +
  ggtitle("Correlation between acousticness and energy (me)")

df.2.cor <- cor(df.2[c(1,2,4:6,8,12)])

ggplot(df.2, aes(x = energy, y = valence)) +
  geom_point() +
  geom_smooth(method = "loess", se = FALSE) +
  ggtitle("Correlation between valence and energy (her)")

ggplot(df.2, aes(x = energy, y = acousticness)) +
  geom_point() +
  geom_smooth(method = "loess", se = FALSE) +
  ggtitle("Correlation between acousticness and energy (her)")

# mean and sd of all scores
mean(as.vector(t(df.1[c(1,2,4:6,8,12)])))

mean(as.vector(t(df.2[c(1,2,4:6,8,12)])))

sd(as.vector(t(df.1[c(1,2,4:6,8,12)])))

sd(as.vector(t(df.2[c(1,2,4:6,8,12)])))




# Boringness

# NOTE: for loudness, the higher the value, the loudest the song

# NOTE: the lowest boringness is, the more boring the song is
boringness <- function(df){
  return ((df$loudness) + (df$energy*100) + (df$danceability*100) + (df$tempo))
}

boring.1 <- data.frame(boringness = boringness(df.1), uri = df.1$uri, who = 'me')
head(arrange(boring.1, (boringness)), 30)
head(arrange(boring.1, desc(boringness)), 30)
summary(boring.1)

ggplot(boring.1, aes(boringness)) +
  geom_histogram() +
  ggtitle("Histogram of the boringness score (me)")

boring.2 <- data.frame(boringness = boringness(df.2), uri = df.2$uri, who = 'her')

ggplot(boring.2, aes(boringness)) +
  geom_histogram() +
  ggtitle("Histogram of the boringness score (her)")

boring.total <- rbind(boring.2, boring.1)
ggplot(boring.total, aes(x = boringness, fill = who)) +
  geom_histogram(alpha=0.6, position='identity')

head(arrange(boring.2, (boringness)))
head(arrange(boring.2, desc(boringness)))

summary(boring.2)

boring.stats <- data.frame(mean = c(mean(boring.1$boringness), mean(boring.2$boringness)),
                           sd = c(sd(boring.1$boringness), sd(boring.2$boringness)),
                           who = c('me', 'her'))


ggplot(boring.stats, aes(x = who,y = mean,fill = who)) +
  geom_bar(stat="identity") +
  ggtitle("Boringness Score Mean")

ggplot(boring.stats, aes(x = who,y = sd,fill = who)) +
  geom_bar(stat="identity") +
  ggtitle("Boringness Score standard deviation")

# Write a csv with just the implicit audio features
implicit.1 <- df.1[c('energy', 'liveness', 'speechiness', 'acousticness', 'instrumentalness', 'danceability', 'valence')]
implicit.2 <- df.2[c('energy', 'liveness', 'speechiness', 'acousticness', 'instrumentalness', 'danceability', 'valence')]
implicit.1$who <- 'me'
implicit.2$who <- 'her'
implicit <- rbind(implicit.1, implicit.2)
write.table(implicit, file='implicit_features.csv', row.names = FALSE, sep=',')



